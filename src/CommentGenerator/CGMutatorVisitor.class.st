"
I represent a Nodevisitor

I visit an Assignment AST Node to see if the created variable is an InstanceVariable.


I can be instancialized like so:

visitor := CGMutatorVisitor new.
method ast acceptVisitor: visitor.

(method here has to be a CompiledMethod) 

"
Class {
	#name : #CGMutatorVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'result'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #accessing }
CGMutatorVisitor >> initialize [

	super initialize.
	result := false
]

{ #category : #accessing }
CGMutatorVisitor >> result [

	^ result
]

{ #category : #visiting }
CGMutatorVisitor >> visitAssignmentNode: anAssignmentNode [

	"TODO: check for ReturnNode to be Boolean or not available"

	super visitAssignmentNode: anAssignmentNode.
	anAssignmentNode variable isInstanceVariable ifTrue: [ 
		result := true ]
]
