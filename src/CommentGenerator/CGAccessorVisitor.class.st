"
I represent a RBProgrammeNodeVisitor.

I get passed a method and evaluate if it is an accessor method.
I map over the methods ASTs and clean up specific nodes if need be.
I look for variables that are returned and are not primitve types.

I have classstereotype: 
- Boundary
	I function as a communication point between classes. I have a lot of collaborational methods but few controller and fewer factory methods.
	
I can be instancialized like so:

visitor := CGAccessorVisitor new.
method ast acceptVisitor: visitor.

(method here has to be a CompiledMethod)

I am using the classes: 
 - Integer
 - InstanceVariableSlot
 - Float
 - RBProgramNodeVisitor
 - Character
 - Fraction
 - Boolean
 - Array


I get used by class: 
 - CGIdentifier


I have relevant public methods which are ordere by their usage:
	Externally :
		 - visitMethodNode:

	Internally
		 - cleanedUpVariableFor: lets me check if the Value of a ReturnNode which is MessageNode is a 		further MessageNode and then returns me the final variable
		 - visitMethodNode: visits a methodNode and returns a 'result' value if the method classifies as an accessor method
		 - cleanedUpBlockFor: lets me check if the Value of a ReturnNode which is MessageNode is a 		BlockNode and then returns me the final variable


My instance variables are: 
 - result


My defining keywords are: 
for,up,cleaned,node,method,visit,result,variable,initialize,block
"
Class {
	#name : #CGAccessorVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'result'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #'helper methods' }
CGAccessorVisitor >> cleanedUpBlockFor: aBlockNode [

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
CGAccessorVisitor >> cleanedUpVariableFor: aMessageNode [

	"A method used to cleanup recursive messageNodes"

	aMessageNode isVariable
		ifTrue: [ ^ aMessageNode variable ]
		ifFalse: [ 
			aMessageNode isLiteralNode
				ifTrue: [ ^ aMessageNode value]
				ifFalse: [ 
					aMessageNode isAssignment 
				ifTrue: [ ^ aMessageNode variable ]
				ifFalse: [ 
					aMessageNode isBlock
						ifTrue: [ ^ self cleanedUpBlockFor: aMessageNode ]
						ifFalse: [ 
							aMessageNode isDynamicArray
								ifTrue: [ ^(aMessageNode allStatements) at:1 ]
								ifFalse: [ 
									aMessageNode isReturn
								ifTrue: [ (aMessageNode value isMessage) ifTrue: [  ^(self cleanedUpVariableFor: (aMessageNode value))]
									ifFalse:[^aMessageNode value variable]]
								ifFalse: [ 
									aMessageNode value receiver isMessage
										ifTrue: [ 
										^ self cleanedUpVariableFor: aMessageNode value receiver ]
										ifFalse: [ 
											aMessageNode value receiver isBlock
												ifTrue: [ 
												^ self cleanedUpBlockFor: aMessageNode value receiver ]
												ifFalse: [ 
													aMessageNode isAssignment ifTrue: [ 
														^ aMessageNode variable variable ].
													^ aMessageNode value receiver value ] ] ] ] ] ] ] ]
]

{ #category : #initialization }
CGAccessorVisitor >> initialize [

	super initialize.
	result := false.
	
]

{ #category : #accessing }
CGAccessorVisitor >> result [

	^ result
]

{ #category : #visiting }
CGAccessorVisitor >> visitMethodNode: aMethodNode [

	| primitives |
	"defining an array with the primitve classes => As smalltalk has not as many Number definitions as others we only have 6 (since we included 	Fractions and InstanceVariableSlots as a primitve as well. Mainly because we define those as Accessors as well)"
	primitives := Array new: 6.
	primitives at: 1 put: Character.
	primitives at: 2 put: Integer.
	primitives at: 3 put: Float.
	primitives at: 4 put: Fraction.
	primitives at: 5 put: Boolean.
	primitives at: 6 put: InstanceVariableSlot.



	super visitMethodNode: aMethodNode.
	aMethodNode body do: [ :sequenceNode | 
		sequenceNode statements do: [ :subNode | 
			subNode isReturn ifTrue: [ 
				subNode value isMessage
					ifTrue: [ 
						primitives do: [ :primitive | 
							primitive class ~~ (self cleanedUpVariableFor: subNode) class 
								ifTrue: [ result := true ] ] ]
					ifFalse: [ 
						subNode value isCascade
							ifTrue: [ 
								primitives do: [ :primitive | 
									subNode value messages do: [ :messageNode | 
										primitive class
										~~ (self cleanedUpVariableFor: messageNode) class ifTrue: [ 
											result := true ] ] ] ]
							ifFalse: [ 
								subNode value isLiteralNode
									ifTrue: [ 
										primitives do: [ :primitive | 
											primitive category ~~ subNode value value class ifTrue: [ 
												result := true ] ] ]
									ifFalse: [ 
										subNode value isDynamicArray
											ifTrue: [ 
												primitives do: [ :primitive | 
													subNode value statements do: [ :message | 
														primitive category
														~~ (self cleanedUpVariableFor: message) class ifTrue: [ 
															result := true ] ] ] ]
											ifFalse: [ 
												subNode value isBlock
													ifTrue: [ 
														primitives do: [ :primitive | 
															subNode value body statements do: [ :message | 
																primitive category
																~~ (self cleanedUpVariableFor: message) class ifTrue: [ 
																	result := true ] ] ] ]
													ifFalse: [ 
														primitives do: [ :primitive | 
															primitive category ~~ subNode value variable class 
																ifTrue: [ result := true ] ] ] ] ] ] ] ] ] ]
]
