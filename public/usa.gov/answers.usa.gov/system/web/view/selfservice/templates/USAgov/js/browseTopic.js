/* $version_start$ 21/04/2009$eGainBlue$1.0 $version_end$ */

function clickTopic(topicId, topicType, startingId, topicName, parentTopicId, parentTopicType, source, topicHrchy) {
	var win = window.name.indexOf("ArticleDetails") >= 0 ? opener : window;
	var ssForm = win.getForm('ssForm');
	win.setFormValue(ssForm, 'TOPIC_ID', topicId);
	win.setFormValue(ssForm, 'TOPIC_TYPE', topicType);
	win.setFormValue(ssForm, 'STARTING_ID', startingId);
	win.setFormValue(ssForm, 'TOPIC_NAME', unescape(topicName));
	win.setFormValue(ssForm, 'PARENT_TOPIC_ID', parentTopicId);
	win.setFormValue(ssForm, 'PARENT_TOPIC_TYPE', parentTopicType);
	win.setFormValue(ssForm, 'SOURCE_FORM', source);
	win.setFormValue(ssForm, 'TOPIC_HIERARCHY', topicHrchy);
	win.setFormValue(ssForm, 'TOP_LEVEL_TOPIC', parentTopicId);

	if (parentTopicId==-1) {
		win.setFormValue(ssForm, 'SIDE_LINK_TOPIC_ID', topicId);
		win.setFormValue(ssForm, 'SIDE_LINK_SUB_TOPIC_ID', -1);
	} else {
		win.setFormValue(ssForm, 'SIDE_LINK_TOPIC_ID', parentTopicId);
		win.setFormValue(ssForm, 'SIDE_LINK_SUB_TOPIC_ID', topicId);
	}

	var expandedTopicTreeNodes = getFormValue('ssForm', 'EXPANDED_TOPIC_TREE_NODES');

	if(expandedTopicTreeNodes!=null){

		if(expandedTopicTreeNodes.indexOf(""+topicId)>0){
			markTopicCollapsed(topicId);
		}
		else{
			markTopicExpanded(topicId);
		}
	}
	return win.submitSSForm(ssForm, 'BROWSE_TOPIC');
}

function expand(evt, elt, topicId) {
	elt.style.display = 'none'; // the span containing the expander image
	do { elt = elt.nextSibling; } while (elt.nodeName.toUpperCase() != 'SPAN');
	elt.style.display = 'inline'; // the span containing the collapser image
	elt = elt.parentNode; // the dt containing images and topic name text
	do { elt = elt.nextSibling; } while (elt.nodeName.toUpperCase() != 'DD');
	elt.style.display = 'block'; // the sub topics

	markTopicExpanded(topicId);
}

function collapse(evt, elt, topicId) {
	elt.style.display = 'none'; // the span containing the collapser image
	do { elt = elt.previousSibling; } while (elt.nodeName.toUpperCase() != 'SPAN');
	elt.style.display = 'inline'; // the span containing the expander image
	elt = elt.parentNode; // the dt containing images and topic name text
	do { elt = elt.nextSibling; } while (elt.nodeName.toUpperCase() != 'DD');
	elt.style.display = 'none'; // the sub topics

	markTopicCollapsed(topicId);
}

function expandAll(evt) {
	var topicTreeModule = document.getElementById('topicTreeModule');
	var elts = topicTreeModule.getElementsByTagName('IMG');
	for (var i = 0; i < elts.length; i++) {
		if (elts[i].alt == 'expand') {
			topicId = elts[i].parentNode.parentNode.id.substring('topic'.length);
			expand(evt, elts[i].parentNode, topicId);
		}
	}
}

function collapseAll(evt) {
	var topicTreeModule = document.getElementById('topicTreeModule');
	var elts = topicTreeModule.getElementsByTagName('IMG');
	for (var i = 0; i < elts.length; i++) {
		if (elts[i].alt == 'collapse') {
			topicId = elts[i].parentNode.parentNode.id.substring('topic'.length);
			collapse(evt, elts[i].parentNode, topicId);
		}
	}
}

function markTopicExpanded(topicId) {
	// write the topic into the EXPANDED_TOPIC_TREE_NODES form input
	var expandedTopicTreeNodes = getFormValue('ssForm', 'EXPANDED_TOPIC_TREE_NODES');
	if (expandedTopicTreeNodes.match(' ' + topicId + ' ') != null) return;
	if (expandedTopicTreeNodes.length == 0) expandedTopicTreeNodes = ' ';
	expandedTopicTreeNodes += topicId + ' ';
	// todo expand all parents recursively
	setFormValue('ssForm', 'EXPANDED_TOPIC_TREE_NODES', expandedTopicTreeNodes);
}

function markTopicCollapsed(topicId) {
	// remove the topic from the EXPANDED_TOPIC_TREE_NODES form input
	var expandedTopicTreeNodes = getFormValue('ssForm', 'EXPANDED_TOPIC_TREE_NODES');
	expandedTopicTreeNodes = expandedTopicTreeNodes.replace(' ' + topicId + ' ', ' ');
	setFormValue('ssForm', 'EXPANDED_TOPIC_TREE_NODES', expandedTopicTreeNodes);
}