"
I represent a SycSingleClassCommand.
I creat an additionall icon in the right-click menu for classes in the system browser, that allows users to creat stereotype based class comments from the sys browser.

I have classstereotype: 
- DataProvider
	I encapsulate data. I consist mostly  of accessor methods.

I am using the classes: 
 - CommentGenerator
 - CmdContextMenuActivation
 - ClyClassContextOfFullBrowser
 - SycSingleClassCommand


I get used by class: 


I have relevant public methods which are ordere by their usage:
	Externally :
		 - defaultMenuItemName: the name that appears in the pop-up menu
		 - defaultMenuIconName: the icon that appears in the pop-up menu

	Internally




My defining keywords are: 
name,menu,default,icon,execute,item
"
Class {
	#name : #CgGenerateClassCommentCommand,
	#superclass : #SycSingleClassCommand,
	#category : #CommentGenerator
}

{ #category : #acccessing }
CgGenerateClassCommentCommand class >> fullBrowserMenuActivation [
	<classAnnotation>
	
	^CmdContextMenuActivation byRootGroupItemOrder: 10000 for: ClyClassContextOfFullBrowser 
]

{ #category : #accessing }
CgGenerateClassCommentCommand >> defaultMenuIconName [
	^#edit
]

{ #category : #accessing }
CgGenerateClassCommentCommand >> defaultMenuItemName [
	^'Generate sterotype-based Class Comment'
]

{ #category : #execution }
CgGenerateClassCommentCommand >> execute [

	| cg |
	cg := CommentGenerator new.
	cg targetClass: targetClass.
	cg generateDocument inspect
]
