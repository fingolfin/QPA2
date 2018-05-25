#! @Chapter Ideals

#! @Section Categories for ideals

#!
DeclareCategory( "IsQuiverAlgebraLeftIdeal", IsQuiverAlgebraIdeal );

#!
DeclareCategory( "IsQuiverAlgebraRightIdeal", IsQuiverAlgebraIdeal );

#!
DeclareCategory( "IsQuiverAlgebraTwoSidedIdeal", IsQuiverAlgebraIdeal );

#! @Section Constructing ideals

#! @Description
#!  Create the two-sided ideal generated by the elements <A>gens</A>
#!  in the quiver algebra <A>A</A>.
#! @Returns IsQuiverAlgebraTwoSidedIdeal
#! @Arguments A, gens
DeclareOperation( "QuiverAlgebraTwoSidedIdeal", [ IsQuiverAlgebra, IsDenseList ] );

#! @Description
#!  Create the left ideal generated by the elements <A>gens</A>
#!  in the quiver algebra <A>A</A>.
#! @Returns IsQuiverAlgebraTwoSidedIdeal
#! @Arguments A, gens
DeclareOperation( "QuiverAlgebraLeftIdeal", [ IsQuiverAlgebra, IsDenseList ] );

#! @Description
#!  Create the right ideal generated by the elements <A>gens</A>
#!  in the quiver algebra <A>A</A>.
#! @Returns IsQuiverAlgebraTwoSidedIdeal
#! @Arguments A, gens
DeclareOperation( "QuiverAlgebraRightIdeal", [ IsQuiverAlgebra, IsDenseList ] );

#! @Description
#!  Create the ideal generated by the elements <A>gens</A>
#!  in the quiver algebra <A>A</A>.
#!  The argument <A>side</A> determines whether to create a
#!  left, right or two-sided ideal.
#! @Returns IsQuiverAlgebraTwoSidedIdeal
#! @Arguments side, A, gens
DeclareOperation( "QuiverAlgebraIdeal", [ IsSide, IsQuiverAlgebra, IsDenseList ] );

# DeclareOperation( "LeftIdealByGenerators", [ IsQuiverAlgebra, IsDenseList ] );
# DeclareOperation( "RightIdealByGenerators", [ IsQuiverAlgebra, IsDenseList ] );
# DeclareOperation( "TwoSidedIdealByGenerators", [ IsQuiverAlgebra, IsDenseList ] );


#! @Section Information about an ideal

#! @Description
#!  Returns the algebra containing the ideal <A>I</A>.
#! @Returns IsQuiverAlgebra
#! @Arguments I
DeclareAttribute( "AlgebraOfIdeal", IsQuiverAlgebraIdeal );

#! @Description
#!  Returns the generators of the ideal <A>I</A>.
#! @Returns list of IsQuiverAlgebraElement
#! @Arguments I
DeclareAttribute( "Generators", IsQuiverAlgebraIdeal );

#! @Description
#!  Checks if <A>I</A> is an admissible ideal.
#! @Returns IsBool
#! @Arguments I
DeclareProperty( "IsAdmissibleIdeal", IsPathAlgebraIdeal );


#! @Section Ideals as modules

#! @Description
#!  The ideal <A>I</A> viewed as a module.
#! @Returns IsQuiverModule
#! @Arguments I
DeclareAttribute( "IdealAsModule", IsQuiverAlgebraIdeal );

#! @Description
#!  The ideal <A>I</A> viewed as a submodule of the algebra.
#!  The result is the inclusion map from the module corresponding to <A>I</A>
#!  into the module corresponding to the algebra.
#! @Returns IsQuiverModuleHomomorphism
#! @Arguments I
DeclareAttribute( "IdealAsSubmoduleOfAlgebra", IsQuiverAlgebraIdeal );

#! @Description
#!  Given an algebra element <A>a</A> which lies in the ideal <A>I</A>,
#!  returns the corresponding module element in <C>IdealAsModule(I)</C>.
#! @Returns IsQuiverModuleElement
#! @Arguments a, I
DeclareOperation( "IdealElementAsModuleElement", [ IsQuiverAlgebraElement, IsQuiverAlgebraIdeal ] );

#! @Description
#!  Given a module element <A>m</A> which lies in the module <C>IdealAsModule(I)</C>,
#!  returns the corresponding algebra element.
#! @Returns IsQuiverAlgebraElement
#! @Arguments m, I
DeclareOperation( "ModuleElementAsIdealElement", [ IsQuiverModuleElement, IsQuiverAlgebraIdeal ] );


#! @Section Basis

#!
# DeclareAttribute( "Basis", IsQuiverAlgebraIdeal );

#!
DeclareCategory( "IsQuiverAlgebraIdealBasis", IsBasis );

#!
DeclareAttribute( "IdealOfBasis", IsQuiverAlgebraIdealBasis );


#! @Section Groebner basis

#! @Arguments I
#! @Returns list of <Ref Filt="IsPathAlgebraElement"/>
#! @Description
#!  A Groebner basis for the ideal <A>I</A>.
DeclareAttribute( "GroebnerBasis", IsPathAlgebraIdeal );

