function DragObject(element) {	element.dragObject = this		dragMaster.makeDraggable(element)		var rememberPosition	var mouseOffset		this.onDragStart = function(offset) {		var s = element.style		rememberPosition = {top: s.top, left: s.left, position: s.position}		s.position = 'absolute'				mouseOffset = offset	}		this.name = function() {		var info = element.getElementsByTagName('div');		for(var i=0; i<info.length; i++) {			if ( info[i].id == 'name' ) {				return info[i].innerHTML;			}		}	}		this.passwd = function() {		var info = element.getElementsByTagName('div');		for(var i=0; i<info.length; i++) {			if ( info[i].id == 'passwd' ) {				return info[i].innerHTML;			}		}	}		this.proxy = function() {		var info = element.getElementsByTagName('div');		for(var i=0; i<info.length; i++) {			if ( info[i].id == 'proxy' ) {				return info[i].innerHTML;			}		}	}		this.hide = function() {		element.style.display = 'none' 	}		this.show = function() {		element.style.display = '' 	}		this.onDragMove = function(x, y) {		element.style.top =  y - mouseOffset.y +'px'		element.style.left = x - mouseOffset.x +'px'	}		this.onDragSuccess = function(dropTarget) { }		this.onDragFail = function() {		var s = element.style		s.top = rememberPosition.top		s.left = rememberPosition.left		s.position = rememberPosition.position	}		this.toString = function() {		return element.id	}}