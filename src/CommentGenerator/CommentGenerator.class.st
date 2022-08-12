"
Classname: CommentGenerator

I am using the classes: 
 - Object
 - CGFormatter
 - WriteStream
 - String


I get used by classes: 
 - CgGenerateClassCommentCommand
 - ClassDescription


I have relevant public methods which are ordere by their usage:
	Externally : 
	- generateDocument: It runs the process of creating method and class stereotypes for the targetClass
	- targetClass: : It lets me set a targetClass

	Internally


My instance variables are: 
 - targetClass
 - targetPackage


My defining keywords are: 
class,target,document,generate
"
Class {
	#name : #CommentGenerator,
	#superclass : #Object,
	#instVars : [
		'targetClass',
		'targetPackage'
	],
	#category : #'CommentGenerator-Core'
}

{ #category : #generators }
CommentGenerator >> generateDocument [

	"This the main public method to generate a comment for the target class"

	| w formatter |
	formatter := CGFormatter new.
	formatter targetClass: targetClass.
	formatter initializeIdentifier.
	w := WriteStream on: String new.
	formatter formatClassnameOn: w.
	w
		cr;
		cr.
	formatter formatClassStereotypeOn: w.
	w
		cr;
		cr.
	formatter formatUsersOn: w.
	w
		cr;
		cr.
	formatter formatUsedByOn: w.
	w
		cr;
		cr.
	formatter formatPublicMethodsOn: w.
	w
		cr;
		cr.

	formatter formatInstanceVariablesOn: w.
	w
		cr;
		cr.
	formatter formatKeywordsOn: w.
	^ w contents
]

{ #category : #accessing }
CommentGenerator >> targetClass [
	^ targetClass
]

{ #category : #accessing }
CommentGenerator >> targetClass: aPharoClass [
	targetClass := aPharoClass.
	targetPackage := targetClass package.
]
