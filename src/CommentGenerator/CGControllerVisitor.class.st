"
I represent a RBProgrammeNodeVisitor.

I get passed a method and evaluate if it is an accessor method.
I map over the methods ASTs.
I look for objects that are instantiated that have a different class than targetClass.
I check if we do any manipulation on self.



I have classstereotype: 
- Controller
	I process data from other class and access their functionalities. I have a multitude of controller methods.
	
I can be instancialized like so:

visitor := CGControllerVisitor new.
method ast acceptVisitor: visitor.

(method here has to be a CompiledMethod)

I am using the classes: 
 - Character
 - RBProgramNodeVisitor


I get used by class: 
 - CGIdentifier


I have relevant public methods which are ordere by their usage:
	Externally :
		 - result
		 - visitMethodNode:

	Internally
		 - result
		 - visitMethodNode:
		 - checkForExternalObjectCreation:
		 - checkForExternalObjectManipulation:


My instance variables are: 
 - result


My defining keywords are: 
object,external,for,check,node,method,visit,manipulation,result,initialize
"
Class {
	#name : #CGControllerVisitor,
	#superclass : #RBProgramNodeVisitor,
	#instVars : [
		'result'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #'helper methods' }
CGControllerVisitor >> checkForExternalObjectCreation: anAssignmentNode [

	| wordArray methodString objectString |
	anAssignmentNode value isMessage ifFalse: [ ^ self ].
	wordArray := anAssignmentNode value asString splitOn: Character space.
	objectString := (wordArray at: 1)
		                copyFrom: 15
		                to: (wordArray at: 1) size.
	wordArray ifNil: [ ^ self ].
	(wordArray at: 2) = '' ifTrue: [ ^ self ].
	methodString := (wordArray at: 2)
		                copyFrom: 1
		                to: (wordArray at: 2) size - 1.
	^ 'new' = methodString asLowercase
]

{ #category : #'helper methods' }
CGControllerVisitor >> checkForExternalObjectManipulation: aMethodNode [
"Checks if we do any manipulation on self"
	^((aMethodNode variableWith: 'self') ~= nil)
]

{ #category : #initialization }
CGControllerVisitor >> initialize [

	super initialize.
	result := false
]

{ #category : #initialization }
CGControllerVisitor >> result [

	^ result
]

{ #category : #visiting }
CGControllerVisitor >> visitMethodNode: aMethodNode [

	|objectCreation objectManipulation|

	"check if we change state of external Object"

	super visitMethodNode: aMethodNode.
	objectManipulation := (self checkForExternalObjectManipulation: aMethodNode).
	aMethodNode body do: [ :sequenceNode | 
		sequenceNode statements do: [ :subNode | 
			subNode isAssignment ifTrue: [ 
				objectCreation := (self checkForExternalObjectCreation: subNode).
				objectCreation class = self class ifTrue: [ ^self ].
				(objectCreation or: objectManipulation) ifTrue: [
					result := true ] ] ] ]
]
