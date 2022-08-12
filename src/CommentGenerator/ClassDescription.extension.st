Extension { #name : #ClassDescription }

{ #category : #'*CommentGenerator' }
ClassDescription >> classCommentBlank [
	"Classes can override this method to show another template."
	"There are two use cases: a class hierarchy can give information about what kind of comment is 
	useful (see 'PackageManifest class'). If in addition, '#hasComment ^true' can be implemented in 
	cases where the class does not need a dedicated comment. See 'TestCase class'for an example"

	|cg|

cg := CommentGenerator new.
cg targetClass: self .
^cg generateDocument .
]
