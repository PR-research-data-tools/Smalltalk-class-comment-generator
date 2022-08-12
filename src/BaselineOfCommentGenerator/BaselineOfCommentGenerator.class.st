Class {
	#name : #BaselineOfCommentGenerator,
	#superclass : #BaselineOf,
	#category : #BaselineOfCommentGenerator
}

{ #category : #accessing }
BaselineOfCommentGenerator >> baseline: spec [
	<baseline>
	
	spec for: #'common' do: [spec package: 'CommentGenerator']
]
