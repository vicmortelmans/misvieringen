module namespace scrape = 'http://www.prentenmissaal.com/misvieringen/lib/scrape';
import module namespace http = 'http://www.zorba-xquery.com/modules/http-client';
import module namespace yql = 'http://www.prentenmissaal.com/misvieringen/lib/yql';
import module namespace geohash = 'http://www.prentenmissaal.com/misvieringen/lib/geohash';
import module namespace geoplaces = 'http://www.prentenmissaal.com/misvieringen/lib/geoplaces';
import module namespace data = 'http://www.prentenmissaal.com/misvieringen/lib/data';
import module namespace store = "http://www.28msec.com/modules/store";

declare %an:sequential %an:nondeterministic function scrape:dioceses() {
  (: this handler will fetch data from kerknet.be,
     process the data into XML records,
     store the records in the database,
     return a small report as RSS :)
  for $diocesePagesUrl in (
    "zoek_parochie.php?allbisdom=1",
    "zoek_parochie.php?allbisdom=2",
    "zoek_parochie.php?allbisdom=3",
    "zoek_parochie.php?allbisdom=4",
    "zoek_parochie.php?allbisdom=6",
    "zoek_parochie.php?allbisdom=7"
  )
  return
  {
      variable $diocesePagesYqlParam as xs:string := "select * from html where url='http://kerknet.be/%url' and xpath='//span[contains(@class,""pagelinks"")][1]/a[not(contains(.,""Volgende""))]/@href'";
      variable $diocesePagesYql as xs:string := fn:replace($diocesePagesYqlParam,"%url",$diocesePagesUrl);
      variable $diocesePages := yql:run($diocesePagesYql);
      for $dioceseUrl in ($diocesePagesUrl,$diocesePages//@href)
      return
      {
          variable $dioceseYqlParam as xs:string := "select * from html where url='http://www.kerknet.be/%url' and xpath='//table[contains(@class,""parochies"")]//td[contains(@class,""col3"")]'";
          variable $dioceseYql as xs:string := fn:replace($dioceseYqlParam,"%url",$dioceseUrl);
          variable $diocese := yql:run($dioceseYql);
          for $parishUrl in $diocese//td//@href (: for debugging use $diocese//td[position() < 2]//@href :)
          return
          {
            variable $parishYqlParam as xs:string := "select * from html where url='http://www.kerknet.be%url' and xpath='//div[contains(@id,""middle"")]'";
            variable $parishYql as xs:string := fn:replace($parishYqlParam,"%url",$parishUrl);
            variable $parishFiche := yql:run($parishYql);
            variable $address := fn:replace(fn:replace(normalize-space(fn:string-join($parishFiche//table[contains(@class,"contact first")]/tr/td/p/text())),"[0-9/.\-+ ]{5,}.*$",""),"'","");
            variable $geohash as xs:string := geohash:run($address);
            variable $geolonlat := geoplaces:run($address);
            variable $name := normalize-space(xs:string($parishFiche//table[contains(@class,"fiche")]/thead/tr[1]));
            variable $masses := <masses/>;
            for $day in $parishFiche//table[contains(@class,"fiche")]/tbody/tr
            return
            {
                variable $weekday as xs:string := normalize-space(xs:string($day/th));
                for $mass in $day/td/p/text()[matches(.,"^[0-9]{2}\.[0-9]{2}u")]
                return
                {
                    variable $time := normalize-space
                    (
                      if (fn:matches($mass,' '))
                      then fn:substring-before($mass,' ')
                      else $mass
                    );
                    variable $description := normalize-space
                    (
                      if (fn:matches($mass,' '))
                      then fn:substring-after($mass,' ')
                      else "eucharistieviering"
                    );
                    variable $record := 
                    <mass>
                        <name>{$name}</name>
                        <address>{$address}</address>
                        <geohash-spot>{$geohash}</geohash-spot>
                        <geohash>{fn:substring($geohash,1,6)}</geohash>
                        <url>{concat("http://www.kerknet.be",$parishUrl)}</url>
                        <lon>{$geolonlat[1]/text()}</lon>
                        <lat>{$geolonlat[2]/text()}</lat>
                        <weekday-condition>{$weekday}</weekday-condition>
                        <description>{$description}</description>
                        <time>{$time}</time>
                        <hour>{substring($time,1,2)}</hour>
                        <minutes>{substring($time,4,2)}</minutes>
                        <timestamp>{fn:current-dateTime()}</timestamp>
                    </mass>;
                    db:apply-insert-last($data:masses,fn:trace($record,"input for apply-insert-last "));
                    store:flush();
                    (: yet anoher strange thing... I read that db:apply-insert-last() 
                       directly applied the updates, but it seems that it still needs 
                       a store:flush() to do so :)
                }
            }
        }
    }
  }};