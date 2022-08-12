"
I represent methods to identifiy various heuristics needed to comment a class

I create lists of different variables which should be entered in the comment format.
I take different SystemNavigation operators to create this information.

I try to interact with most classes, so I can get their information.

Public API and Key Messages

- message one   
- message two 
- (for bonus points) how to create instances.

   One simple example is simply gorgeous.
 
Internal Representation and Key Implementation Points.

    Instance Variables
	statements:		<Object>
	targetClass:		<Object>


    Implementation Points
"
Class {
	#name : #CGIdentifier,
	#superclass : #CommentGenerator,
	#instVars : [
		'accessors',
		'get',
		'mutators',
		'set',
		'collaborators',
		'controllers',
		'nonCollaborators',
		'creators',
		'methods',
		'degenerates',
		'classStereotypes',
		'methodStereotypes'
	],
	#classInstVars : [
		'relevantVariables',
		'targetClass'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #'class stereotyping' }
CGIdentifier >> classStereotypes [

	^ classStereotypes
]

{ #category : #'class stereotyping' }
CGIdentifier >> getClassStereotype [

	"depening on the methodStereotypes for targetClass we want to get the correct classStereotype"

	classStereotypes := OrderedCollection new.
	self getMethodStereotypes .
	methods ifEmpty: [
		classStereotypes add: 'Empty'.
		^classStereotypes ].
	
	self isEntity ifTrue: [ classStereotypes add: 'Entity' ].
	self isMinimalEntity ifTrue: [ classStereotypes add: 'MinimalEntity' ].
	self isSmall ifTrue: [ classStereotypes add: 'Small' ].
	self isCommander ifTrue: [ classStereotypes add: 'Commander' ].
	self isBoundary ifTrue: [ classStereotypes add: 'Boundary' ].
	self isFactory ifTrue: [ classStereotypes add: 'Factory' ].
	self isController ifTrue: [ classStereotypes add: 'Controller' ].
	self isPureController ifTrue: [ classStereotypes add: 'PureController' ].
	self isLarge ifTrue: [ classStereotypes add: 'Large' ].
	self isLazy ifTrue: [ classStereotypes add: 'Lazy' ].
	self isDegenerateClass ifTrue: [ classStereotypes add: 'Degenerate' ].
	self isDataClass ifTrue: [ classStereotypes add: 'Data' ].
	self isDataProvider ifTrue: [ classStereotypes add: 'DataProvider' ].
	
	classStereotypes ifEmpty: [ classStereotypes add: '' ].
	
^classStereotypes.
]

{ #category : #'class accessing' }
CGIdentifier >> getDependentClasses [
"Return the list of classes used by self"
	^ targetClass dependentClassesWithOccurences
]

{ #category : #'instancevariables accessing' }
CGIdentifier >> getInstanceVariables [
	"returns all the relevant instance variables"	
	^ targetClass instanceVariables.
	
]

{ #category : #'method accessing' }
CGIdentifier >> getMethodStereotypes [
"gets all public methods and returns them as a dictionary with their according stereotype"
	
			
	| publicMethods results |
	results := Dictionary new.
	publicMethods := self getRelevantMethods. 
	publicMethods do: [ :method | results at: method put:( self getStereotypeForMethod: method)].
	
^results
]

{ #category : #'method accessing' }
CGIdentifier >> getMostUsedMethodForCollection: aCollection [

	"A collection of methods. Counting how often each method is used and returning them in an ordered 	fashion"

	| senders internalResultDictionary temp externalResultDictionary resultInternal resultExternal |
	temp := ($- split: targetPackage name) first.
	resultInternal := OrderedCollection new.
	resultExternal := OrderedCollection new.
	internalResultDictionary := Dictionary new.
	externalResultDictionary := Dictionary new.
	aCollection do: [ :method | 
		senders := (SystemNavigation default allSendersOf: method) 
			           groupedBy: [ :m | m package name beginsWith: temp ].
		"internal"
		senders
			at: true
			ifPresent: [ 
			internalResultDictionary at: method put: (senders at: true) size ].
		"external"
		senders
			at: false
			ifPresent: [ 
			externalResultDictionary at: method put: (senders at: false) size ] ].
	((internalResultDictionary associations sort: #value descending) 
		 collect: #key) do: [ :method | resultInternal add: method ].
	((externalResultDictionary associations sort: #value descending) 
		 collect: #key) do: [ :method | resultExternal add: method ].

	^ Dictionary new
		  at: 'internal' put: resultInternal;
		  at: 'external' put: resultExternal;
		  yourself
]

{ #category : #'method accessing' }
CGIdentifier >> getMostUsedMethodsForStereotype [

	"Depending on the ClassStereotype we only want to look at specific methods which have been 	used"

	| tempCollection |
	tempCollection := OrderedCollection new.
	self getClassStereotype.
	((classStereotypes includes: 'Empty') or:
		 (classStereotypes includes: 'Small'))
		ifTrue: [ tempCollection addAll: methods ]
		ifFalse: [ 
			(classStereotypes includes: 'DataProvider')
				ifTrue: [ 
					tempCollection addAll: accessors.
					tempCollection addAll: get ]
				ifFalse: [ 
					(classStereotypes includes: 'Entity')
						ifTrue: [ 
							tempCollection addAll: accessors.
							tempCollection addAll: mutators.
							tempCollection addAll: creators ]
						ifFalse: [ 
							(classStereotypes includes: 'MinimalEntity')
								ifTrue: [ 
									tempCollection addAll: get.
									tempCollection addAll: set.
									tempCollection addAll: mutators ]
								ifFalse: [ 
									(classStereotypes includes: 'Commander')
										ifTrue: [ 
											tempCollection addAll: mutators.
											tempCollection addAll: set ]
										ifFalse: [ 
											(classStereotypes includes: 'Boundary')
												ifTrue: [ tempCollection addAll: collaborators ]
												ifFalse: [ 
													(classStereotypes includes: 'Factory')
														ifTrue: [ tempCollection addAll: creators ]
														ifFalse: [ 
															(classStereotypes includes: 'Controller')
																ifTrue: [ 
																	tempCollection addAll: controllers.
																	tempCollection addAll: creators.
																	tempCollection addAll: accessors.
																	tempCollection addAll: mutators ]
																ifFalse: [ 
																	(classStereotypes includes: 'PureController')
																		ifTrue: [ 
																			tempCollection addAll: controllers.
																			tempCollection addAll: creators ]
																		ifFalse: [ 
																			(classStereotypes includes: 'Large')
																				ifTrue: [ tempCollection addAll: methods ]
																				ifFalse: [ 
																					(classStereotypes includes: 'Lazy')
																						ifTrue: [ 
																							tempCollection addAll: get.
																							tempCollection addAll: set.
																							tempCollection addAll: degenerates ]
																						ifFalse: [ 
																							(classStereotypes includes: 'Degenerate')
																								ifTrue: [ tempCollection addAll: degenerates  ]
																								ifFalse: [ 
																									(classStereotypes includes: 'Data') ifTrue: [ 
																										tempCollection addAll: get.
																										tempCollection addAll: set. ] ] ] ] ] ] ] ] ] ] ] ] ].
	^ self getMostUsedMethodForCollection: tempCollection
]

{ #category : #'classreference accessing' }
CGIdentifier >> getRelevantClassReferences [
	"Return the list of classes, alphabetically ordered, that use the targetClass"
	| methods |
	methods := SystemNavigation default allReferencesTo: (targetClass environment bindingOf: targetClass name).
	^ ((methods collect: #methodClass) asSet asSortedCollection: [ :c1 :c2 | c1 name < c2 name ]) asArray
]

{ #category : #'keyword accessing' }
CGIdentifier >> getRelevantKeyWords [
"returns a list of the most frequently used keywords"

	| keyWords |
	keyWords := ((((targetClass selectors flatCollect: #splitCamelCase) collect: [ :k | 
		   k asLowercase copyWithoutAll: ':' ]) groupedBy: #yourself)
		 associations sort: [ :assoc1 :assoc2 | 
		 assoc1 value size > assoc2 value size ]) collect: #key.

	^ keyWords
]

{ #category : #'method accessing' }
CGIdentifier >> getRelevantMethods [
	| blackListMethods |
	blackListMethods := #(#initialize).
	^ targetClass selectors copyWithoutAll: blackListMethods.
]

{ #category : #'method stereotyping' }
CGIdentifier >> getStereotypeForMethod: aMethod [

	"Deciding the stereotype of a aMethod. Can be: accessors, mutators, factory, collaborater, controller or degenerate"

	methodStereotypes at: aMethod put: Set new.

	(self isMutator: aMethod) ifTrue: [ 
		(methodStereotypes at: aMethod) add: 'Mutator'.
		mutators add: aMethod.
		(self isMutatorSet: aMethod) ifTrue: [ 
			(methodStereotypes at: aMethod) add: 'MutatorSet'.
			set add: aMethod ] ].

	(self isCollaborator: aMethod) ifTrue: [ 
		(methodStereotypes at: aMethod) add: 'Collaborator'.
		collaborators add: aMethod.
		(self isController: aMethod) ifTrue: [ 
			(methodStereotypes at: aMethod) add: 'Controller'.
			controllers add: aMethod ] ]
		ifFalse: [ nonCollaborators add: aMethod ].

	(self isFactory: aMethod) ifTrue: [ 
		(methodStereotypes at: aMethod) add: 'Creator'.
		creators add: aMethod ].

	(self isAccessor: aMethod) ifTrue: [ 
		(methodStereotypes at: aMethod) add: 'Accessor'.
		accessors add: aMethod.
		(self isAccessorGet: aMethod) ifTrue: [ 
			(methodStereotypes at: aMethod) add: 'AccessorGet'.
			get add: aMethod ] ].

	(methodStereotypes at: aMethod) ifEmpty: [ 
		(methodStereotypes at: aMethod) add: 'Degenerate'.
		degenerates add: aMethod ].

	methods add: aMethod.
	^ methodStereotypes at: aMethod
]

{ #category : #initialization }
CGIdentifier >> initialize [

	super initialize.
	methodStereotypes := IdentityDictionary new.
	accessors := OrderedCollection new.
	get := OrderedCollection new.
	mutators := OrderedCollection new.
	set := OrderedCollection new.
	collaborators := OrderedCollection new.
	nonCollaborators := OrderedCollection new.
	creators := OrderedCollection new.
	controllers := OrderedCollection new.
	degenerates := OrderedCollection new.
	methods := OrderedCollection new.
]

{ #category : #'method stereotyping' }
CGIdentifier >> isAccessor: aSymbol [
	"gets a method-name as a Symbol and checks if this method is a Accessor method or not. Returns a 	boolean
	
   To identify the stereotype Accessor the following conditions need to be satisfied: 
   • method returns an instance variable or primitive"

	| method visitor |
	method := targetClass >> aSymbol.
	visitor := CGAccessorVisitor new.
	method ast acceptVisitor: visitor.
	^ visitor result
]

{ #category : #'method stereotyping' }
CGIdentifier >> isAccessorGet: aSymbol [

	"To identify the stereotype Getter the following conditions need to be satisfied: 
   • method is accessor alreadys
   • returns only data members i.e. instance variables"

	| method ast seq ret var |
	method := targetClass >> aSymbol.
	ast := method ast.
	
	ast children size = 1 ifFalse: [ ^ false ].
	
	seq := ast children first.
	seq class == RBSequenceNode ifFalse: [ ^ false ].
	
	seq children size = 1 ifFalse: [ ^ false ].
	ret := seq children first.
	ret class == RBReturnNode ifFalse: [ ^ false ].
	
	
	var := ret children first.
	var class == RBVariableNode ifFalse: [ ^ false ].
	
	^ method selector = var name
]

{ #category : #'class stereotyping' }
CGIdentifier >> isBoundary [

	"• More collaborators then non-collaborators
		|collaborators| > |non-collaborators|
		
	• Not all the methods are factory methods
		|factory| < ½ * |methods|
		
	• Low number of controller methods
		|controller| < 1/3 * |methods|"

	(collaborators size > nonCollaborators size and: [ 
		 creators size < (methods size / 2) and: [ 
			 controllers size < (methods size / 3) ] ]) ifTrue: [ ^ true ].
	^ false
]

{ #category : #'method stereotyping' }
CGIdentifier >> isCollaborator: aSymbol [
"To identify the stereotype Collaborator one of the following statements needs to be satisfied: 
  • At least one variable that is manipulated or passed in the method has to be an object
• The object being handled cannot be a primitive "
	
	| method visitor |
	method := targetClass >> aSymbol.
	visitor := CGCollaboratorVisitor new.
	method ast acceptVisitor: visitor.
	^ visitor result
]

{ #category : #'class stereotyping' }
CGIdentifier >> isCommander [

	"• It consists mostly of mutators
		|mutators| > 2 * |accessors|
		
	• Low control of other classes
		|mutators| > 2 * (|controller| + |factory|)"

	mutators size > (2 * accessors size) ifTrue: [ 
		mutators size > (2 * (controllers size + creators size)) 
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isController [

	"• High control of other classes
		|controller| + |factory| > 2/3 * |methods|
		
	• Accessor or mutator are present (not only methods that work on external objects exist)
		|accessors| != 0 or |mutators| != 0"

	controllers size + creators size > (2 * methods size / 3) ifTrue: [ 
		(accessors isNotEmpty  or: mutators isNotEmpty ) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'method stereotyping' }
CGIdentifier >> isController: aSymbol [
"To identify the stereotype Controler one of the following statements needs to be satisfied: 
  • The method only creates or manipulates external objects i.e., objects
	that are created or manipulated are not of the same class as the target
	class "
	
	| method visitor |
	method := targetClass >> aSymbol.
	visitor := CGControllerVisitor new.
	method ast acceptVisitor: visitor.
	^ visitor result
]

{ #category : #'class stereotyping' }
CGIdentifier >> isDataClass [

	"• Only the simple accessor/mutators get and set are present:
		|get| + |set| != 0 & |methods| – (|get| + |set|) = 0"

	get size + set size > 0 ifTrue: [ 
		(get size + set size - methods size) = 0 ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isDataProvider [

	"•It consists mostly of accessors
		|accessors| > 2 * |mutators|
	
	• Low control of other classes
		|accessors| > 2 * (|controller| + |factory|)"

	accessors size > (2 * mutators size) ifTrue: [ 
		accessors size > (2 * (controllers size + creators size)) 
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isDegenerateClass [

	"• It consists of many degenerate methods
		|degenerate| / |methods| > ½"

	methods isNotEmpty ifTrue: [ 
		degenerates size / methods size > (1 / 2) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isEntity [

	"logic for deciding if class is a Entity Class
	From Dragan:
	To identify the class stereotype Entity the following conditions need to be satisfied:
	• They contain an accessor besides get and a mutator besides set
	{accessors} - {get} != 0 && {mutators} - {set} != 0
	• The ratio of collaborational to non-collaborational methods is 2:1 => 5% margin of error
	|collaborators| / |non-collaborators| = 2
	• They can have factory methods but no controller methods
	|controller| != 0"

	(accessors size - get size > 0 and: [ mutators size - set size > 0 ]) 
		ifTrue: [ 
			nonCollaborators isNotEmpty ifTrue: [ 
				(collaborators size / nonCollaborators size
					 closeTo: 2
					 precision: 0.1) ifTrue: [ 
					controllers isEmpty ifTrue: [ ^ true ] ] ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isFactory [

	"• It consists mostly of factory methods
		|factory| > 2/3 * |methods|"

	creators size > (2 * methods size / 3) ifTrue: [ ^ true ].
	^ false
]

{ #category : #'method stereotyping' }
CGIdentifier >> isFactory: aSymbol [

	"To identify the stereotype Creator the following conditions need to be satisfied: 
  • returns an object created in the method’s body"	
	
	| method visitor |
	method := targetClass >> aSymbol.
	visitor := CGCreatorVisitor new.
	method ast acceptVisitor: visitor.
	^ visitor result
]

{ #category : #'class stereotyping' }
CGIdentifier >> isLarge [

	"• Categories of stereotypes (accessor with mutator) and stereotypes, factory and controller, are approximately in equal 		proportions
		1/5 * |methods| < |accessors| + |mutators| < 2/3 * |methods|
		& 1/5 * |methods| < |factory| + |controller| < 2/3 * |methods|
		
	• Controller and factory have to be present
		|factory| != 0 & |controller|!= 0
		
	• Accessor and mutator have to be present
		|accessors| != 0 & |mutators|!= 0"

	creators isNotEmpty ifTrue: [ 
		controllers isNotEmpty ifTrue: [ 
			accessors isNotEmpty ifTrue: [ 
				mutators isNotEmpty ifTrue: [ 
					methods size / 5 < (accessors size + mutators size) ifTrue: [ 
						accessors size + mutators size < (2 * methods size / 3) ifTrue: [ 
							methods size / 5 < (controllers size + creators size) ifTrue: [ 
								controllers size + creators size < (2 * methods size / 3) 
									ifTrue: [ ^ true ] ] ] ] ] ] ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isLazy [

	"• It has to contain get/set methods
		|get| + |set| != 0
		
	• It might have a large number of degenerate methods
		|degenerate| / |methods| > 1/3

	• Occurrence of other stereotypes is low
		|methods| – (|get| + |set| + |degenerate|) <= 1/5"

	get size + set size > 0 ifTrue: [ 
		degenerates size / methods size > (1/3) ifTrue: [ 
			methods size - (get size + set size + degenerates size) <= (1
			/ 5) ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isMinimalEntity [

	"• The only method stereotypes are get, set, and
	command/non-void-command
	{methods} - ({get} U {set} U {command} U {non-void-command}) = 0 
	& |get| != 0 & |set| != 0
	& ({command} U {non-void-command}) != 0  => by default command + non-void-command = Mutators this script
	• The ratio of collaborational to non-collaborational methods is 2:1 => 5% margin of Erro
	|collaborators| / |non-collaborators| = 2"

	methods size - (get size + set size + mutators size) = 0 ifTrue: [ 
		get isNotEmpty ifTrue: [ 
			set isNotEmpty ifTrue: [ 
				mutators isNotEmpty ifTrue: [ 
					nonCollaborators isNotEmpty ifTrue: [ 
						(collaborators size / nonCollaborators size
							 closeTo: 2
							 precision: 0.1) ifTrue: [ ^ true ] ] ] ] ] ].
	^ false
]

{ #category : #'method stereotyping' }
CGIdentifier >> isMutator: aSymbol [

	"To identify the stereotype Mutator the following conditions need to be satisfied: 
  	• The method changes the state of an object
	• There are no return types or only boolean returns"

	| method visitor |
	method := targetClass >> aSymbol.
	visitor := CGMutatorVisitor new.
	method ast acceptVisitor: visitor.
	^ visitor result
]

{ #category : #'method stereotyping' }
CGIdentifier >> isMutatorSet: aSymbol [

	"To identify the stereotype Setter the following conditions need to be satisfied: 
  • The method must be a Mutator already
	• The method changes only the state of one instance variable"

	| method ast seq ass |
	method := targetClass >> aSymbol.
	ast := method ast.
	
	ast children size = 2 ifFalse: [ ^ false ].
 
	seq := ast children second.
	seq class == RBSequenceNode ifFalse: [ ^ false ].
	seq children size = 1 ifFalse: [ ^ false ].
	
	ass := seq children first.
	ass children size = 2 ifFalse: [ ^ false ].
	ass children second class == RBVariableNode ifFalse: [ ^ false ].
	^ method methodClass instVarNames includes: ass children second name
]

{ #category : #'class stereotyping' }
CGIdentifier >> isPureController [

	"• Only controller and factory methods with no mutator, accessor, or collaborator methods
		|controller| + |factory| != 0 & |accessors| + | mutators| + |collaborator| = 0
	• There must be at least one controller method
		|controller| != 0"

	controllers isNotEmpty  ifTrue: [ 
		( controllers size + creators size > 0 ) ifTrue: [
			(accessors size + mutators size + collaborators size = 0) ifTrue: [ ^ true ] ]].
	^ false
]

{ #category : #'class stereotyping' }
CGIdentifier >> isSmall [

	"• Number of methods in a class is less than 3:
		|methods| < 3"

	methods isNotEmpty ifTrue:[
		methods size < 3 ifTrue: [ ^ true ]].
	^ false
]

{ #category : #'method accessing' }
CGIdentifier >> publicMethods [
	"Return the method names that are considered as public in the target class. Returns ordered 	Collection"
	| senders results |
	results := OrderedCollection new.
	self getRelevantMethods do: [ :methodName | 
		senders := SystemNavigation default allSendersOf: methodName.
		(senders anySatisfy: [ :method | method methodClass ~~ targetClass ])
			ifTrue: [ results add: methodName ] ].
	results sort .
	^results
]

{ #category : #'example accessing' }
CGIdentifier >> relevantExamples [
	"returning Examples found in a class"
	"scope: class-variables  &  instance-variables"	
			
	| results |
	results := OrderedCollection new.
	"TODO: implement method to run over class-code and filter-out everything that has an example tag"
]

{ #category : #'method stereotyping' }
CGIdentifier >> separateMethodStereotypesFor: aMethodStereotypeDictionary [

	accessors := OrderedCollection new.
	get := OrderedCollection new.
	mutators := OrderedCollection new.
	set := OrderedCollection new.
	collaborators := OrderedCollection new.
	nonCollaborators := OrderedCollection new.
	creators := OrderedCollection new.
	controllers := OrderedCollection new.
	degenerates := OrderedCollection new.
	methods := OrderedCollection new.

	aMethodStereotypeDictionary keysAndValuesDo: [ :method :stereotype | 
		stereotype = 'Accessor'
			ifTrue: [ accessors add: method ]
			ifFalse: [ 
				stereotype = 'AccessorGet'
					ifTrue: [ get add: method ]
					ifFalse: [ 
						stereotype = 'Mutator'
							ifTrue: [ mutators add: method ]
							ifFalse: [ 
								stereotype = 'MutatorSet'
									ifTrue: [ set add: method ]
									ifFalse: [ 
										stereotype = 'Collaborator'
											ifTrue: [ collaborators add: method ]
											ifFalse: [ 
												stereotype = 'Creator'
													ifTrue: [ creators add: method ]
													ifFalse: [ 
														stereotype = 'Controller'
															ifTrue: [ controllers add: method ]
															ifFalse: [ 
															stereotype = 'Degenerate' ifTrue: [ 
																degenerates add: method ] ] ] ] ] ] ] ] ].

	"itterating a second time to get all methods and all the methods that are not Collaborators (has to 	be done seperatly and not 	with ~= since otherwise it aborts for all the methods beforehand in the 	upper loop"
	aMethodStereotypeDictionary keysDo: [ :method | 
		methods add: method.
		(collaborators includes: method) ifFalse: [ 
			nonCollaborators add: method ] ]
]

{ #category : #accessing }
CGIdentifier >> targetClass: aPharoClass [

	super targetClass: aPharoClass.
]
