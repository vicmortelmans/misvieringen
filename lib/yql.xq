module namespace yql = 'http://www.prentenmissaal.com/misvieringen/lib/yql';
import module namespace http = 'http://www.zorba-xquery.com/modules/http-client';
import module namespace sleep = "http://www.28msec.com/modules/sleep";
import module namespace functx = "http://www.functx.com/";
declare %an:sequential %an:nondeterministic function yql:run($yql as xs:string) {
    variable $urlParam as xs:string := "http://query.yahooapis.com/v1/public/yql?q=%yql";
    variable $url as xs:string := fn:replace($urlParam,"%yql",fn:encode-for-uri($yql));
    variable $result := http:get-node($url)[2]/*; (: [2] skips the headers :)
    sleep:millis(1000);
    functx:change-element-ns-deep($result,"","")
};