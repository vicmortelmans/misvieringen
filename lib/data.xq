module namespace data = 'http://www.prentenmissaal.com/misvieringen/lib/data';
declare collection data:masses as node()*; 
declare variable $data:masses as xs:QName := xs:QName("data:masses");
(:
declare %an:automatic %an:value-equality index data:day-index
  on nodes db:collection(xs:QName("data:masses"))
  by ./weekday-condition as xs:string;
:)
declare %an:automatic %an:nonunique %an:value-equality index data:geohash-index
  on nodes db:collection(xs:QName("data:masses"))
  by xs:string(./geohash) as xs:string;
  (: omitting 'xs:string()' here causes 'Zorba data-definition error 
     [zerr:ZDTY0011]: item type "UNTYPED_ATOMIC" does not match declared 
     type "xs:string" for key expression of index data:geohash-index' :)