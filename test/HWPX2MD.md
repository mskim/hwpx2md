^<\?xml (.|\n)*?</hp:secPr> -> delete
<hp:footNote number="([0-9]*)" (.|\n)*?<hp:autoNum num="([0-9]*)" (.|\n)*?<hp:t>((.)*?)</hp:t>(.|\n)*?</hp:footNote>    -> [^$1] "[^$3]$5" # 주석처리
<[/]?hp:ctrl> -> delete
<[/]?hp:run>  -> delete
<hp:run (.)*?"[/]?>  -> delete
<[/]?hp:p>  -> delete
<hp:p (.)*?"[/]?>  -> delete
<hp:colPr (.)*?"[/]?> -> delete
</hs:sec>  -> delete
<hp:pageNum (.)*?"[/]?>  -> delete

<hp:linesegarray>(.|\n)*?</hp:linesegarray> -> \n
<hp:lineBreak/>  -> \n

<[/]?hp:t>  -> delete










