"
I represent a RBProgrammeNodeVisitor.

I get passed a method and evaluate if it is an accessor method.
I map over the methods ASTs.
I check if a variable passed to a method is not a primitive, if so i return 'result' as true

I have classstereotype: 
- Boundary
	I function as a communication point between classes. I have a lot of collaborational methods but few controller and fewer factory methods.
	
I can be instancialized like so:

visitor := CGCollaboratorVisitor new.
method ast acceptVisitor: visitor.

(method here has to be a CompiledMethod)

I am using the class: 
 - RBProgramNodeVisitor


I get used by class: 
 - CGIdentifier


I have relevant public methods which are ordere by their usage:
	Externally :
		 - visitMethodNode: visits a methodNode and returns a 'result' value if the method classifies as a collaborator method

	Internally
		 - visitMethodNode: visits a methodNode and returns a 'result' value if the method classifies as a collaborator method
		 - checkForPrimitves: checks if the assignment to the method is a primitive value by comparing its string values to representative string values for primitives


My instance variables are: 
 - result


My defining keywords are: 
node,method,visit,result,initialize,primitves,for,check
"
Class {
	#name : #CGCollaboratorVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'result'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #'helper methods' }
CGCollaboratorVisitor >> checkForPrimitves: aMethodArgumentVariable [

	| primitiveKeyWords |
	primitiveKeyWords := #( 'boolean' 'has' 'is' 'can' 'integer' 'number' 'float' 'count' 'double' 'char' 'character' 'byte'  ).

	(aMethodArgumentVariable asString) splitCamelCase do: [ :word | 
		^ primitiveKeyWords includes: (word asLowercase) ]
]

{ #category : #initialization }
CGCollaboratorVisitor >> initialize [

	super initialize.
	result := false
]

{ #category : #initialization }
CGCollaboratorVisitor >> result [

	^ result
]

{ #category : #visiting }
CGCollaboratorVisitor >> visitMethodNode: aMethodNode [

"check if variable is an Object that is not a primitve"
	super visitMethodNode: aMethodNode .
	aMethodNode arguments do: [ :aMethodArgument | 
		aMethodArgument isVariable ifTrue:[
		(self checkForPrimitves: (aMethodArgument variable)) ifFalse:[
			result := true ]]].
]
