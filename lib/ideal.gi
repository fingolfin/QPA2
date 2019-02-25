DeclareSideOperations( IsQuiverAlgebraIdeal,
                       IsQuiverAlgebraLeftIdeal, IsQuiverAlgebraRightIdeal,
                       IsQuiverAlgebraTwoSidedIdeal );

DeclareSideOperations( QuiverAlgebraIdeal,
                       QuiverAlgebraLeftIdeal, QuiverAlgebraRightIdeal,
                       QuiverAlgebraTwoSidedIdeal );

InstallMethodWithSides( QuiverAlgebraIdeal, [ IsQuiverAlgebra, IsDenseList ],
side -> function( A, gens )
  local I, ideal_cat, type;
  I := rec();
  if IsPathAlgebra( A ) and side = LEFT_RIGHT then
    ideal_cat := IsQuiverAlgebraIdeal ^ side and IsPathAlgebraIdeal;
  else
    ideal_cat := IsQuiverAlgebraIdeal ^ side;
  fi;    
  type := NewType( FamilyObj( A ),
                   ideal_cat
                   and IsComponentObjectRep
                   and IsAttributeStoringRep );
  ObjectifyWithAttributes( I, type,
                           Side, side,
                           AlgebraOfIdeal, A,
                           Generators, gens,
                           LeftActingDomain, LeftActingDomain( A ) );
  SetParent( I, A );
  
  return I;
end );

InstallMethod( LeftIdealByGenerators, [ IsQuiverAlgebra, IsCollection and IsDenseList ],
               QuiverAlgebraLeftIdeal );
InstallMethod( RightIdealByGenerators, [ IsQuiverAlgebra, IsCollection and IsDenseList ],
               QuiverAlgebraRightIdeal );
InstallMethod( TwoSidedIdealByGenerators, [ IsQuiverAlgebra, IsCollection and IsDenseList ],
               QuiverAlgebraTwoSidedIdeal );
               

InstallMethod( String, "for quiver algebra ideal",
               [ IsQuiverAlgebraIdeal ],
function( I )
  local side_str, gens_str;
  if Side( I ) = LEFT_RIGHT then
    side_str := "two-sided";
  else
    side_str := String( Side( I ) );
  fi;
  if IsEmpty( Generators( I ) ) then
    return Concatenation( "<", side_str, " zero ideal>" );
  fi;
  gens_str := Iterated( List( Generators( I ), String ),
                        function( a, b ) return Concatenation( a, ", ", b ); end );
  return Concatenation( "<", side_str, " ideal generated by ", gens_str, ">" );
end );

InstallMethod( ViewObj, "for quiver algebra ideal",
               [ IsQuiverAlgebraIdeal ],
function( I )
  Print( String( I ) );
end );

# operations from GAP:
InstallMethod( GeneratorsOfLeftIdeal, [ IsQuiverAlgebraLeftIdeal ], Generators );
InstallMethod( GeneratorsOfRightIdeal, [ IsQuiverAlgebraRightIdeal ], Generators );
InstallMethod( GeneratorsOfTwoSidedIdeal, [ IsQuiverAlgebraTwoSidedIdeal ], Generators );
InstallMethod( LeftActingRingOfIdeal, [ IsQuiverAlgebraLeftIdeal ], AlgebraOfIdeal );
InstallMethod( LeftActingRingOfIdeal, [ IsQuiverAlgebraTwoSidedIdeal ], AlgebraOfIdeal );
InstallMethod( RightActingRingOfIdeal, [ IsQuiverAlgebraRightIdeal ], AlgebraOfIdeal );
InstallMethod( RightActingRingOfIdeal, [ IsQuiverAlgebraTwoSidedIdeal ], AlgebraOfIdeal );
InstallMethod( IsIdeal, "for ring and quiver algebra ideal",
               [ IsRing, IsQuiverAlgebraIdeal ],
function( R, I )
  return R = AlgebraOfIdeal( I );
end );

InstallMethod( IdealAsSubmoduleOfAlgebra, [ IsQuiverAlgebraIdeal ],
function( I )
  local side, A;
  A := AlgebraOfIdeal( I );
  if not IsFiniteDimensional( A ) then
    Error( "algebra is not finite-dimensional" );
  fi;
  side := Side( I );
  return SubmoduleInclusion( AlgebraAsModule( side, A ),
                             List( Generators( I ), AsModuleElement ^ side ) );
end );

InstallMethod( IdealAsModule, [ IsQuiverAlgebraIdeal ],
               I -> Source( IdealAsSubmoduleOfAlgebra( I ) ) );

InstallMethod( \in, [ IsQuiverAlgebraElement, IsQuiverAlgebraIdeal ],
function( a, I )
  local inc, M, module_elem;
  inc := IdealAsSubmoduleOfAlgebra( I );
  M := IdealAsModule( I );
  module_elem := PreImagesRepresentative( inc, AsModuleElement( Side( M ), a ) );
  return module_elem <> fail;
end );

InstallMethod( GroebnerBasis, "for path algebra ideal",
               [ IsPathAlgebraIdeal ],
               I -> ComputeGroebnerBasis( Generators( I ) ) );

InstallMethod( \in, "for element of path algebra and path algebra ideal",
               [ IsPathAlgebraElement, IsPathAlgebraIdeal ],
function( e, I )
  return e in AlgebraOfIdeal( I )
         and IsZero( Reduce( e, GroebnerBasis( I ) ) );
end );

InstallMethod( IdealElementAsModuleElement, [ IsQuiverAlgebraElement, IsQuiverAlgebraIdeal ],
function( a, I )
  local inc, M, module_elem;
  inc := IdealAsSubmoduleOfAlgebra( I );
  M := IdealAsModule( I );
  module_elem := PreImagesRepresentative( inc, AsModuleElement( Side( M ), a ) );
  if module_elem = fail then
    Error( "algebra element ", a, " is not in the ideal ", I );
  fi;
  return module_elem;
end );

InstallMethod( ModuleElementAsIdealElement, [ IsQuiverModuleElement, IsQuiverAlgebraIdeal ],
function( m, I )
  local inc;
  inc := IdealAsSubmoduleOfAlgebra( I );
  return AsAlgebraElement( Image( inc, m ) );
end );

InstallMethod( IsAdmissibleIdeal, [ IsPathAlgebraIdeal ],
function( I )
  local gens, kQ, Q, A, is_reducible, path_length, paths, next_paths, p, a;

  kQ := AlgebraOfIdeal( I );
  if IsZeroIdeal( I ) then
    return IsFiniteDimensional( kQ );
  fi;

  gens := GeneratorsOfIdeal( I );
  
  # check I \subseteq J^2:
  if not ForAll( gens, g -> ForAll( Paths( g ), IsCompositePath ) ) then
    return false;
  fi;

  # check J^t \subseteq I:
  Q := QuiverOfAlgebra( kQ );
  A := kQ / I;

  if not IsFiniteDimensional( A ) then
    return false;
  fi;

  is_reducible :=
    p ->
    ( Representative( PathAsAlgebraElement( A, p ) )
      <> PathAsAlgebraElement( PathAlgebra( A ), p ) );

  path_length := 1;
  paths := Arrows( Q );
  next_paths := [];

  while not ForAll( paths, is_reducible ) do
    for p in paths do
      for a in OutgoingArrows( Target( p ) ) do
        Add( next_paths, ComposePaths( p, a ) );
      od;
    od;
    path_length := path_length + 1;
    paths := next_paths;
    next_paths := [];
  od;

  return ForAll( paths, p -> IsZero( PathAsAlgebraElement( A, p ) ) );
end );

InstallMethod( IsZeroIdeal, "for quiver algebra ideal",
               [ IsQuiverAlgebraIdeal ],
function( I )
  return ForAll( Generators( I ), IsZero );
end );

BindGlobal( "FamilyOfQuiverAlgebraIdealBases",
            NewFamily( "quiver ideal bases" ) );

InstallMethod( CanonicalBasis, "for quiver algebra ideal",
               [ IsQuiverAlgebraIdeal ],
function( I )
  local basis_vectors, type, B;
  if not IsFiniteDimensional( AlgebraOfIdeal( I ) ) then
    Error( "not implemented" );
  fi;
  basis_vectors := List( Basis( IdealAsModule( I ) ),
                         m -> ModuleElementAsIdealElement( m, I ) );
  type := NewType( FamilyOfQuiverAlgebraIdealBases,
                   IsQuiverAlgebraIdealBasis and IsComponentObjectRep
                   and IsAttributeStoringRep );
  B := rec();
  ObjectifyWithAttributes( B, type,
                           IdealOfBasis, I,
                           BasisVectors, basis_vectors,
                           IsCanonicalBasis, true );
  return B;
end );

InstallMethod( Basis, "for quiver algebra ideal",
               [ IsQuiverAlgebraIdeal ],
               CanonicalBasis );

InstallMethod( UnderlyingLeftModule, "for quiver algebra ideal basis",
               [ IsQuiverAlgebraIdealBasis ],
               IdealOfBasis );

InstallMethod( ProductSpace,
"for ideals in IsQuiverAlgebra",
[ IsQuiverAlgebraIdeal, IsQuiverAlgebraIdeal ],
function ( I, J )
  
  local A, sideI, sideJ, side, gens, BI, BJ, a, b, c;
  
  A := AlgebraOfIdeal( I );
  if A <> AlgebraOfIdeal( J ) then
    Error( "The entered ideals are not in the same algebra.\n" );
  fi;
  if not IsFiniteDimensional( A ) then
    Error( "The entered algebra is not finite dimensional.\n" );
  fi;
  sideI := Side( I );
  sideJ := Side( J );
  if sideI = RIGHT and sideJ = LEFT then
    Error( "Invalid combination for ideals.\n" );
  fi;
  if sideI = sideJ then
    side := sideI;
  elif sideI = RIGHT then
    side := sideI;
  elif sideJ = LEFT then
    side := sideJ;
  else
    side := LEFT_RIGHT;
  fi;
  gens := [ ];
  BI := BasisVectors( Basis( I ) );
  BJ := BasisVectors( Basis( J ) );
  for a in BI do
    for b in BJ do
      c := a * b;
      if not IsZero( c ) then 
        Add( gens, c );
      fi;
    od;
  od;
  gens := Unique( gens );
  
  return QuiverAlgebraIdeal( side, A, gens );
end
  );
  
######################################################################
##
#P  IsMonomialIdeal(<I>)
## 
##  This function returns true if <I> is a monomial ideal, 
##  i.e. <I> is generated by a set of monomials (= "zero-relations").
##  Note:  This uses Groebner bases machinery
##  (which sometimes can cause an infinite loop or another bugs!).
##  It uses an observation: <I> is a monomial ideal <=> Groebner basis 
##  of <I> is a set of monomials.
##  It computes G.b. only in case it has not been computed yet and
##  usual generators of <I> are not monomials.
##
InstallMethod( IsMonomialIdeal,
"for an ideal in a path algebra",
[ IsPathAlgebraIdeal ],
function( I )
    
    local GB, A, rels;

    if HasIsTrivial( I ) and IsTrivial( I ) then
        return true;
    fi;
    
    # Now we have to check if Groebner basis is a set of monomials
    # Checks if GB is a list of monomials
    GB := GroebnerBasis( I );
    
    return ForAll( GB, r -> ( Length( Paths( r ) ) = 1 ) );
end
    ); # IsMonomialIdeal

InstallMethod( NthPowerOfArrowIdeal, 
"for a path algebra",
[ IsPathAlgebra, IS_INT ],
function( A, n ) 

    local   Q,  arrows,  list,  i,  newlist,  p,  outarrows;
   
    Q := QuiverOfAlgebra( A );   
    arrows := Arrows( Q );
    list := arrows; 
    for i in [ 1..n - 1 ] do
        newlist := [ ];
        for p in list do
            outarrows := OutgoingArrows( Target( p ) );
            newlist := Concatenation( newlist, p * outarrows ); 
        od;
        list := newlist;
    od;
    list := List( list, x -> x * One( A ) );
    
    return QuiverAlgebraTwoSidedIdeal( A, list );
end
  );

InstallMethod( AddNthPowerToRelations, 
"for a set of relations in a path algebra",
[ IsPathAlgebra, IsHomogeneousList, IS_INT ], 0, 
function ( kQ, relations, n );
   
   Append( relations, GeneratorsOfTwoSidedIdeal( NthPowerOfArrowIdeal( kQ, n ) ) );   

   return relations; 
end
  );

#######################################################################
##
#O  MinimalGeneratingSetOfIdeal( <I> )
##
##  The argument of this function is an admissible ideal  <I>  in a 
##  path algebra  KQ  a field  K, it returns a  minimal generating set
##  of I. 
##  
##  
InstallMethod( MinimalGeneratingSetOfIdeal, 
"for an admissible ideal in a path algebra",
[ IsAdmissibleIdeal ],
function( I )

    local   generators,  kQ,  arrows,  JIplusIJ,  Aprime,  Ibar,  B;
    #
    #  Finding a generating set for  JI + IJ. 
    #
    generators := GeneratorsOfTwoSidedIdeal( I );
    if Length( generators ) = 0 then
        return [ ];
    fi;
    kQ := AlgebraOfIdeal( I );
    arrows := List( Arrows( QuiverOfAlgebra( kQ ) ), a -> a * One( kQ ) );
    JIplusIJ := List( arrows, x -> Filtered( generators * x, y -> y <> Zero( y ) ) );
    Append( JIplusIJ, List( arrows, x -> Filtered( x * generators, y -> y <> Zero( y ) ) ) );
    JIplusIJ := Flat( JIplusIJ );
    #
    # Constructing the factor kQ/JIplusIJ, if necessary.
    #
    if Length( JIplusIJ ) = 0 then
        return BasisVectors( Basis( I ) );
    fi;
    Aprime := kQ/JIplusIJ;
    #
    # Finding the ideal  I/JIplusIJ  and a basis of this ideal. Pulling this 
    # basis back to kQ and return it.
    # 
    Ibar := List( generators, x -> QuotientOfPathAlgebraElement( Aprime, x ) ); 
    Ibar := Ideal( Aprime, Ibar );
    B := BasisVectors( Basis( Ibar ) );
    
    return List( B, x -> Representative( x ) );
end
  );

#############################################################################
##  
#O  IsQuadraticElements ( <gens> ) 
##  
##  This function returns true, if the list  <gens>  is a list of quadratic
##  elements; false otherwise. 
##  Checks whether the generators passed in have the form
##
##              k1*p1 + k2*p2 + ...
##
##  where each ki is in k and each pi is a path of length 2.  
##
InstallMethod( IsQuadraticElements, 
"for a list of elements in a path algebra",
[ IsHomogeneousList ],
function( gens ) 
 
    local   kQ,  g,  paths;

    kQ := AlgebraOfElement( gens[ 1 ] );
    if not ForAll( gens, g -> AlgebraOfElement( g ) = kQ )  then 
        Error( "The entered elements are not in the same algebra.\n" );
    fi;
    if not IsPathAlgebra( kQ ) then
        Error( "The entered elements are not in a path algebra.\n" );
    fi;
    if not ForAll( gens, g -> g in kQ ) then
        Error( "The entered elements are not in the same path algebra.\n" );
    fi;
    if Length( gens ) = 0 then 
        return true; 
    fi;
    for g in gens do
        paths := Paths( g );
        if not ForAll( paths, p -> Length( p ) = 2 ) then
            return false;
        fi;
    od; 
    
    return true;
end
    );	
