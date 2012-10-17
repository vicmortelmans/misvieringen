module namespace geohash = 'http://www.prentenmissaal.com/misvieringen/lib/geohash';
import module namespace http = 'http://www.zorba-xquery.com/modules/http-client';
import module namespace yql = 'http://www.prentenmissaal.com/misvieringen/lib/yql';
declare %an:sequential %an:nondeterministic function geohash:run($location as xs:string) {
(: geohash.org gives "403 Forbidden Too many requests"
    variable $geohashUrlParam := "http://geohash.org/?q=%location&amp;format=url&amp;redirect=0&amp;maxlen=6";
    variable $geohashUrl := fn:replace($geohashUrlParam,'%location',fn:encode-for-uri(fn:normalize-space($location)));
    http:get-text($geohashUrl)[2]
:)
    variable $yqlParam as xs:string := "use 'https://raw.github.com/vicmortelmans/yql-tables/master/geo/geo.geohash.xml' as geo.geohash; select * from geo.geohash where place='%location' and precision='12'";
    variable $yql as xs:string := fn:replace($yqlParam,"%location",fn:normalize-space($location));
    xs:string(yql:run($yql)//geohash)
};