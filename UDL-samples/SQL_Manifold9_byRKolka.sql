
-- Describing Manifold 9's SQL syntax in Notepad++ UDL 2.1 (User Defined Language) terms.

-- "Operators & Delimiters"
---------------------------

-- Symbol-like "operators", that do not require surrounding whitespace and can itself act as separators between words.
-- Operators 1                                        «%», «&», «*», «+», «-», «/», «<», «<=», «<>», «=», «>», «>=», «^», «,», «::», «.», «;», «(», «)»
-- Should «(», «)»  be here, or Delimiters 6?
-- Should «{», «}»  be here as part of JSON strings


-- Word-like "operators", that require surrounding whitespace or separators
-- Operators 2                                        «AND», «BETWEEN», «BITAND», «LIKE», «MOD», «NOT», «OR», «SPLIT», «UNION», «UNION ALL», «XOR», etc.
-- some might belong to the keyword list 


-- Delimiter pairs
-- Order of {1, 2} and {3, 4, 5} is important
-- Delimiter 1  escapeless string quotes                 «@'»  «'»   
--    NOTE: Operators 1 are nested within quotes to highligth commas inside JSON
--    NOTE: Should Delimiter 5 be nested within quotes to highligth double-quoted strings and values inside JSON?
-- Delimiter 2  string quotes    with «\» escape         «'»   «'»  
-- Delimiter 3  context and expression double-brackets   «[[»  «]]»
-- Delimiter 4  function parameter brackets              «@[»  «]»
-- Delimiter 5  names' brackets (with alternatives)      «[»   «]», «"»   «"», «`»   «`»
-- Delimiter 6  parenthesis (testing, should remove?)    «(»   «)»   
-- Delimiter 7  date hashes                              «#»   «#»
-- Delimiter 8  Expr. eval. and engine directives        «?»   «((EOL))», «!»   «((EOL))»


-- "Comment & Number"
---------------------

-- Line comment start double-dash                        «--»
-- Line comment can start anywhere and continues til the end of line

-- Number formats
-- decimal separator dot                                 «.»
-- no further variants?
-- ?? some cases 32 in FLOAT32 is styled as number?!!!


-- "Keyword lists"
------------------
-- Significant or "keywords"
-- Keyword 1    SQL statements' reserved words        «ALTER TABLE», «AS», «FULL OUTER JOIN», «JOIN», «SELECT», «WHERE», etc.
-- Keyword 2    Builtin function names                «Coord*», «Geom*», «String*», «Tile*», etc.
-- Keyword 3    Builtin types                         «BOOLEAN», «DATETIME», «GEOM», «INT*», «FLOAT*», etc.
-- Keyword 4    Builtin aggregate function names      «Avg», «Count», «GeomMergeAreas», «StringJoinTokens», «Sum», etc.
-- Keyword 5    Builtin constants                     «CRLF», «E», «FALSE», FLOAT32MAX», «NULL», «PI», «TRUE», etc.
-- Keyword 6    free           	  
-- Keyword 7    function parameter prefix ?           «@» 
-- 				NB! Style Keyword 7 same as Delimiter 4
--              Seems we cannot merge Keyword 7 «@» with Delimiter 4 as ⟨«@», « »⟩ pair 
-- Keyword 8    Pragma, collation, etc. options       «AVERAGE», «createdname», «gpgpu», «progress», «nokanatype», etc.
--              NB! Nest Keyword 8 into Delimiter 2 


-- "Folder & default"
---------------------

-- start folding by {{ two opening squiggly braces inside comments
-- many 
-- folded
-- lines
-- end folding by }} two closing squiggly braces inside comments  


-- "Samples"
------------


-- {{  Delimiter 1  «@'»  «'»  sample
SELECT * FROM [Files] WHERE [Path] like @'C:\no\escape\needed\' ;
SELECT * FROM [Orders] WHERE [City] = @'London' ;
-- }}


-- {{  Delimiter 2  «'»   «'»  sample
SELECT * FROM [Orders] WHERE [City] = 'London' ;
SELECT * FROM [Orders] WHERE [City] = '\'s-Hertogenbosch' ;
-- }}


--  {{  Delimiter 3  «[[»  «]]»  sample
EXECUTE WITH (@x INT32 = 2, @y INT32 = 20) [[ INSERT INTO dbo.t (a, b) VALUES (@x@, @y@) ]] ON [sql];

EXECUTE WITH (@n TABLE = [States Table])  
[[
    FUNCTION f(@T TABLE) TABLE AS
      (SELECT Max([Population]) FROM @T) END;
    TABLE CALL f(@n);
]]
;
-- }} 


--  {{  Delimiter 4 «@[»  «]» / Keyword 7  «@» sample
FUNCTION f(@[ a crazy param name $ 5@six.com ] TABLE, @not_bigger_than INT32) TABLE AS
(
	SELECT Max([Population]) FROM @[ a crazy param name $ 5@six.com ] WHERE [Population] < @not_bigger_than
)
END
;
-- }} 


--  {{  Delimiter 5 «[» «]», «`» «`», «"» «"»  sample
SELECT * FROM [2016 Roads];
SELECT * FROM `2016 Roads`;
SELECT * FROM "2016 Roads";
SELECT [Population 1990] FROM [Countries];
SELECT "Population 1990" FROM `Countries`;
-- }} 


--  {{  Delimiter 7 «#» «#» sample
SELECT * FROM [Orders] WHERE [datetime] > #01/21/2017 12:05:15# ;
-- }} 


--  {{  Delimiter 8 «!», «?» sample
!fullfetch
!native
!manifold

? DataLength('SQL is Great!')
-- float64: 28
? DataLength(CAST ('SQL is Great!' AS VARCHAR))
-- float64: 14
-- }} 
 
 
--  {{  Keywords 8 sample
-- Delimiter 2 single-quotes nest Keywords 8 (and Operators 1 and Delimiter 5)
CREATE TABLE [Table] (
	[name] NVARCHAR,
	INDEX [name_x] BTREENULL ([name] COLLATE 'en-US, nocase, noaccent')
);
 
PRAGMA ('gpgpu' = 'aggressive');
PRAGMA ('gpgpu'='aggressive', 'gpgpu.fp'='32')
--}}



--  {{  Tables from datasources using «::» sample

SELECT 
	[USA States].[State], 
	[USA States].[Population], 
	[City Capitals].[Capital]
FROM 
	[USA]::[States] AS [USA States] 
	JOIN 
	[Cities]::[Capitals] AS [City Capitals]
	ON 
	[USA States].[State] = [City Capitals].[State]
;
--}}

--  {{  Function sample
-- Pure SQL/9 function
FUNCTION combine(@p NVARCHAR, @q NVARCHAR) NVARCHAR AS @p & ': ' & @q  END;

-- Function from dll
FUNCTION F(@x FLOAT64) FLOAT64 AS SCRIPT FILE 'math2.dll' ENTRY 'math.Var.F';
--}}

--  {{  JSON double-quoted values in single-quoted string sample
-- Note: Delimiter 2 single-quotes nest Delimiter 5 and Operators 1 (and Keywords 8)
CREATE TABLE [ContinuousColor Table] (
  [mfd_id] INT64,
  [Geom] GEOM,
  [v] FLOAT32,
  [x] FLOAT32,
  [y] FLOAT32,
  INDEX [mfd_id_x] BTREE ([mfd_id]),
  INDEX [Geom_x] RTREE ([Geom]),
  PROPERTY 'FieldCoordSystem.Geom' 'EPSG:3301,mfd:{ "Axes": "XY" }'
);

CREATE DRAWING [ContinuousColor] (
  PROPERTY 'FieldGeom' 'Geom',
  PROPERTY 'StylePointColor' '{ "Value": 11119017 }',
  PROPERTY 'StylePointColorBack' '{ "Field": "v", "Fill": "boundaverage", "Value": 16777215, "Values": { "0": 16777215, "10": 3688006, "15": 15594514, "20": 16777215, "5": 2287079 } }',
  PROPERTY 'StylePointSize' '{ "Value": 8 }',
  PROPERTY 'Table' '[ContinuousColor Table]'
);

-- Query in single-quoted string
CREATE QUERY [Insert_ContinuousColor] (
  PROPERTY 'Text' '
  -- $manifold$
  DELETE FROM [ContinuousColor Table];
  INSERT INTO [ContinuousColor Table] ( [v], [x], [y] )
  SELECT 
	[Value]*20 as [v],
	Trunc([Value]*40*40) div 40 as [x],
	Trunc([Value]*40*40) mod 40 as [y]
  FROM
	CALL ValueSequenceRandom(500, 111)
  ;
'
);
--}}