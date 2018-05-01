module Parser where

import Control.Monad (void)
import Data.Void
import Text.Megaparsec
import Text.Megaparsec.Char
import Text.Megaparsec.Expr
import qualified Text.Megaparsec.Char.Lexer as L 

import PTCL 

type Parser = Parsec Void String

-- TO DO :


--
-- Lexer 
--

-- | spaceConsumer: consume the whitespace, newline,
--                  line comment out, block comment out 
spaceConsumer :: Parser ()
spaceConsumer = L.space space1 lineCmnt blockCmnt 
  where lineCmnt = L.skipLineComment "#"
        blockCmnt = L.skipBlockComment "/*" "*/"

-- | Wrap parser for 'lexeme'
lexeme :: Parser a -> Parser a 
lexeme = L.lexeme spaceConsumer

-- | A helper to parse symbols (special string)
symbol :: String -> Parser String 
symbol = L.symbol spaceConsumer

-- | 'parens' parse things between parenthesis 
parens :: Parser a -> Parser a
parens = between (symbol "(") (symbol ")")

-- | 'integer' parses an integer
integer :: Parser Int
integer = lexeme L.decimal

-- | 'comma' parses a comma ","
comma :: Parser String 
comma = symbol ","

-- | 'bar' parses a bar "|"
bar :: Parser String 
bar = symbol "|"

-- | newline parsers a newline "\n"
newline :: Parser String
newline = symbol "\n"

-- | parses the reservedwords and identifiers 
reservedword :: String -> Parser ()
reservedword w = lexeme (string w *> notFollowedBy alphaNumChar)

-- | list of reserved words
reservedwords :: [String]
reservedwords = ["Atom","Int", "List", "data", "type", "decl", "is"]

-- | ? 
identifier :: Parser String
identifier = (lexeme . try) (p >>= check)
  where
    p       = (:) <$> letterChar <*> many alphaNumChar
    check x = if x `elem` reservedwords
                then fail $ "keyword " ++ show x ++ " cannot be an identifier"
                else return x

--
-- Parser for Build-in Type 
--

buildinType :: Parser Type
buildinType = TAtom <$ reservedword "Atom"
    <|> TInt <$ reservedword "Int"
    <|> TString <$ reservedword "String"
    <|> TList <$ reservedword "List"
    <|> TDef <$> identifier

--
-- Parser for Defined Type
--

-- | parser for user defined type
definedType :: Parser DefinedType
definedType = typeType 
    <|> dataType

-- | parser for type constructor
typeType :: Parser DefinedType 
typeType =  do 
    reservedword "type"
    tName  <- typeName
    tp     <- buildinType
    return $ TypeT tName tp

-- | Parse the type name of user defined
typeName :: Parser TypeName 
typeName = identifier


-- | Parser for data constructor 
dataType :: Parser DefinedType
dataType =  do 
    reservedword "data"
    tyname <- typeName
    void (symbol "=")
    dlist  <- dataCaseList
    return $ DataT tyname dlist 

-- | Parse a list of case in data constructor (separate by "|") 
dataCaseList :: Parser [(ConstructorName,[Type])]
dataCaseList = dataCaseWithArg `sepBy` bar
    <|> dataCaseTerminal `sepBy` bar

-- | parse the name of constructor
consName :: Parser TypeName 
consName = identifier

-- | parse the case of data type (non-terminal)
dataCaseWithArg :: Parser (ConstructorName,[Type])
dataCaseWithArg = do 
    cn      <- consName
    void (symbol "(")
    arglist <- typeList
    void (symbol ")")
    return (cn,arglist)

-- | parse the case of data type (terminal)
dataCaseTerminal :: Parser (ConstructorName,[Type])
dataCaseTerminal = do 
    cn <- consName
    return (cn,[])

-- | Parse a list of buildin Type seperate by comma
typeList :: Parser [Type]
typeList = buildinType  `sepBy` comma












