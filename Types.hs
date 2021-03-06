module Types where
       
import Text.Megaparsec.Pos

-- | Types 
data Type = TAtom | TInt | TString| TList | TVar TypeVar | TDef TypeName [TypeVar]
    deriving(Show, Eq)

type Line = Int 

--
-- * Basic Object of Type Declaration  
--
-- | A list of the type declaration 
type TypeDic = [(Dec,Line)]
type PredicateT = (PredName, [Type])
type FunctorT =   (FuncName,[Type],Type)
data Dec = PredD PredicateT | FuncD FunctorT
    deriving(Show)

-- | Names
type VarName = String -- upper case
type AtomName = String -- lower case 
type PredName = String -- lower case 
type FuncName = String -- lower case 

-- 
-- * User defined type
-- 
type TypeDef = [(DefinedType,Line)]
type TypeName = String -- upper case
type TypeVar = String -- lower case start with _

type ConstructorName = String -- lower case
type Cons = (ConstructorName,[Type])

data DefinedType = TypeT TypeName Type 
                 | DataT TypeName [TypeVar] [Cons]
    deriving(Show)

--
-- * Basic Object of Prolog Program 
-- 

-- | A set of Prolog Predicate 
type Prog = [(Rule,Line)] 

type PredFunA = (String, [Argument])

-- | Rules in Prolog, Head + Body 
data Rule = Head PredFunA Body
    deriving(Show)

data Argument = Atom AtomName 
              | LitI Int 
              | LitS String
              | List [Argument] 
              | Var VarName 
              | Func PredFunA 
              | OperA OptA Argument Argument 
    deriving(Show)
     
-- | Body is a list of BodyElem 
type Body = [BodyElem]

-- | Operation includes Mathematic Operation and comparasion
data OptA =   Sub | Add | Div | Mult| Mod 
    deriving(Show) 

-- | Operation includes Mathematic Operation and comparasion
data OptC =  Eq | Neq  | Lt | Leq | Gt | Gtq 
    deriving(Show) 
    
-- | Element of Body: 
data BodyElem  = Pred PredFunA
     | Is Argument Argument
     | OperC OptC Argument Argument 
     | And BodyElem BodyElem 
     deriving(Show)

--
-- entire prolog program
--
data Prolog = PL (TypeDef, TypeDic, Prog)
    deriving (Show)

     
