module namespace ds = 'http://www.prentenmissaal.com/misvieringen/dataset';
import module namespace scrape = 'http://www.prentenmissaal.com/misvieringen/lib/scrape';
import module namespace data = 'http://www.prentenmissaal.com/misvieringen/lib/data';
import module namespace resp = "http://www.28msec.com/modules/http/response";
import module namespace request = "http://www.28msec.com/modules/http/request";
import module namespace store = "http://www.28msec.com/modules/store";

declare %an:sequential function ds:dump() {
    resp:set-content-type('application/xml');
    <masses>
    {
        db:collection($data:masses)
    }
    </masses>
};

declare %an:sequential function ds:queryRangeAndDay() {
    resp:set-content-type('application/xml');
    variable $range := request:parameter-values("range");
    variable $day := request:parameter-values("day");
    <masses>
    {
        variable $rangeList := fn:tokenize(fn:trace($range,"range to be tokenized "),' ');
        variable $intermediateResults := 
            for $r in $rangeList
            return idx:probe-index-point-value(xs:QName("data:geohash-index"),fn:trace($r,"rangeList "));
            (: strange, I would have assumed that this flwor could be replaced 
               by a single idx:probe-index-point-general(,$rangeList) call, 
               but it says it's not allowed on this index :)    
            (: update: maybe because it's not declared as  'an:general-range', or 'an:general-equality 
               see http://www.zorba-xquery.com/html/documentation/2.6.0/zorba/xqddf :)            
        $intermediateResults[weekday-condition = $day]
    }
    </masses>
};

declare %an:sequential %an:nondeterministic function ds:update() { 
  db:truncate($data:masses); 
  store:flush();
  resp:set-content-type('application/xml');
  scrape:dioceses();
  <report>ds:update() OK</report>
};