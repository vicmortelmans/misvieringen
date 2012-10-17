module namespace geoplaces = 'http://www.prentenmissaal.com/misvieringen/lib/geoplaces';
import module namespace http = 'http://www.zorba-xquery.com/modules/http-client';
import module namespace yql = 'http://www.prentenmissaal.com/misvieringen/lib/yql';
declare %an:sequential %an:nondeterministic function geoplaces:run($location as xs:string) {
    variable $yqlParam as xs:string := "use 'http://www.datatables.org/google/google.geocoding.xml' as google.geocoding; select * from google.geocoding where q='%location'";
    variable $yql as xs:string := fn:replace($yqlParam,"%location",fn:normalize-space($location));
    variable $result := yql:run($yql);
    $result//Point/*
};