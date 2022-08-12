"
I represent a RBProgrammeNodeVisitor

I visit a Method AST Node and its subsequent nodes to define if variables are defined as Assignments also appear in the ReturnNode of the method.


Public API and Key Messages

- cleanedUpVariableFor: lets me check if the Value of a ReturnNode which is MessageNode is a further MessageNode and then returns me the final variable

I can be instancialized like so:

visitor := CGCreatorVisitor new.
method ast acceptVisitor: visitor.

(method here has to be a CompiledMethod)
 

"
Class {
	#name : #CGCreatorVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'result'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #'helper methods' }
CGCreatorVisitor >> cleanedUpBlockFor: aBlockNode [

	"cleaning up ReturnNode if it is aBlockNode"

	aBlockNode body isSequence ifTrue: [ 
		aBlockNode body statements do: [ :statement | 
			statement isMessage ifTrue: [ 
				statement receiver isMessage
					ifTrue: [ ^ self cleanedUpVariableFor: statement receiver ]
					ifFalse: [ 
						statement receiver isBlock
							ifTrue: [ ^self cleanedUpBlockFor: (statement receiver ) ]
							ifFalse: [ ^ statement receiver variable ] ] ].
			statement isLiteralNode ifTrue: [ ^ statement value ] ] ]
]

{ #category : #'helper methods' }
CGCreatorVisitor >> cleanedUpVariableFor: aMessageNode [

	"A method used to cleanup recursive messageNodes"

	aMessageNode value receiver isMessage
		ifTrue: [ ^ self cleanedUpVariableFor: aMessageNode value receiver ]
		ifFalse: [ 
			aMessageNode value receiver isBlock ifTrue: [ 
				^ self cleanedUpBlockFor: aMessageNode value receiver ].
			^ aMessageNode value receiver value ]
]

{ #category : #initialization }
CGCreatorVisitor >> initialize [

	super initialize.
	result := false
]

{ #category : #visiting }
CGCreatorVisitor >> result [

	^ result
]

{ #category : #visiting }
CGCreatorVisitor >> visitMethodNode: aMethodNode [

	| assignmentNodes returnNodes |
	super visitMethodNode: aMethodNode.
	assignmentNodes := OrderedCollection new.
	returnNodes := OrderedCollection new.
	aMethodNode body do: [ :sequenceNode | 
		sequenceNode statements do: [ :element | 
			element isAssignment ifTrue: [ 
				assignmentNodes add: element variable variable ].
			element isReturn ifTrue: [ 
				element value isMessage
					ifTrue: [ returnNodes add: (self cleanedUpVariableFor: element) ]
					ifFalse: [ returnNodes add: element value ] ] ] ].

	returnNodes do: [ :returnVariable | 
		assignmentNodes do: [ :assignmentVariable | 
			assignmentVariable ~~ returnVariable ifTrue: [ result := true ] ] ].

	^ result
]
