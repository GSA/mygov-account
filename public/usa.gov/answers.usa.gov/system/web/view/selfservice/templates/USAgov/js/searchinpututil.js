/* $version_start$ 21/04/2009$eGainBlue$1.0 $version_end$ */
/**
 * Store the topic list in JS array, and use it for re-populating the subtopic drop-down, based on
 * topic selection
 */

var operatorMap = new Array();
var operators = new Array();
var externalizedOperators = new Array();
var attrib = new Object();
var attribList = new Array();
var crTable;
var keywords = '';

var searchButton;
var removeCr;

var crList = new Array();
var cr = new Object();
var len = 0;
var numRows = 1;
var userInputList = new Array();

function onSearchHelp(language, country) {
	var url="help/"+language+"/"+country+"/web/search_tips.htm";
	window.open(url,"Help");
	return false;
}

function openURLinNewWindow(url) {
	window.open(url);
	return false;
}

function checkEnterForAdvancedSearch(evt) {
	/* Handle non-IE browsers */
	var keyCode = (window.event) ? evt.keyCode : evt.which;
	if (keyCode == 13) {
		addCriteria(L10N_SEARCH_BUTTON, L10N_REMOVE_CRITERIA);
		return false;
	}
}

/**
 * Call back for topic selection in TOPIC drop-down Based on the selected topic, populate sub-topic
 * drop-down again Start with selected topic, and populate all its children
 */
function onTopicChange(topicSelectId, subtopicSelectId) {
	try {
		var topicSelect = document.getElementById(topicSelectId);
		var subtopicSelect = document.getElementById(subtopicSelectId);

		if (topicSelect.selectedIndex == 0) {
			subtopicSelect.options.length = 1;
			subtopicSelect.options[0].value = -1;
			subtopicSelect.options[0].text = L10N_SELECT_ALL_SUBTOPICS;
		}
		else {
			var selectedTopicId = topicSelect.options[topicSelect.selectedIndex].value;
			var selectedTopicObject = commonVariables.topicTree.subtopics[selectedTopicId];

			subtopicSelect.options.length = selectedTopicObject.numSubtopics + 1;
			subtopicSelect.options[0].value = selectedTopicId;
			subtopicSelect.options[0].text = L10N_SELECT_ALL_SUBTOPICS;
			subtopicSelect.selectedIndex = 0;

			var i = 1;
			var subtopics = selectedTopicObject.subtopics;
			for (topicId in subtopics) {
				subtopicSelect.options[i].value = topicId;
				subtopicSelect.options[i].text = subtopics[topicId].topicName;
				i++;
			}
		}
	}
	catch(exception) {
		// Do nothing. This is added because if the method is called and the drop-downs do not exist
		// runtime errors will show up
	}
}

function setTopicAndSubtopicUsingId(topicSelectId, subtopicSelectId, topicId, subtopicId) {
	try {
		document.getElementById(topicSelectId).value = topicId;

		onTopicChange(topicSelectId, subtopicSelectId);

		document.getElementById(subtopicSelectId).value = subtopicId;
	}
	catch(exception) {
        // Done to handle the case when the topic drop-down is disabled in the configuration
	}
}

// This function submits the basic search form
function basicSearchSubmit() {
	if (! verify())	return false;
	return submitSSForm("searchForm");
}

// This function submits the advanced search form
function advancedSearchSubmit() {
	if (! go()) return false;
	return submitSSForm("advanceSearchForm");
}

// This function verifies the user input in the basic search form.
var expandedStr = '';

function containsSpecialChars(str) {
	return (str.indexOf('$')>-1 || str.indexOf('#')>-1 || str.indexOf('^')>-1 || str.indexOf('_')>-1);
}

function replaceSpecialChars(str) {
	return str.replace(/[$#^_]/g,"");
}

function verify() {
	keywords = '';
	var searchFrm;
	searchFrm = document.getElementById("searchForm");
	try {
		var selectedTopicIndex = searchFrm.TOPIC.selectedIndex;
		var selectedSubTopicIndex = searchFrm.SUBTOPIC.selectedIndex;
		searchFrm.SIDE_LINK_TOPIC_ID.value = searchFrm.TOPIC.options[selectedTopicIndex].value;
		searchFrm.SIDE_LINK_SUB_TOPIC_ID.value = searchFrm.SUBTOPIC.options[selectedSubTopicIndex].value;
	}
	catch(exception) {
		// Done to handle the case when the topic drop-down is disabled in the configuration
	}

	if (searchFrm.TOPIC) {
		var selectedTopicIndex = searchFrm.TOPIC.selectedIndex;
		var selectedSubTopicIndex = searchFrm.SUBTOPIC.selectedIndex;
		searchFrm.TOPIC_NAME.value = '';
		searchFrm.SUBTOPIC_NAME.value = '';

		if (selectedTopicIndex > 0) {
			var elt = searchFrm.TOPIC.getElementsByTagName('OPTION')[selectedTopicIndex];
			str = elt.text || elt.innerText || elt.textContent;
			str = str.replace(/^[\s]+/, '').replace(/[\s]+$/, '');
			searchFrm.TOPIC_NAME.value = str;
		}
		if (selectedSubTopicIndex > 0) {
			var elt = searchFrm.SUBTOPIC.getElementsByTagName('OPTION')[selectedSubTopicIndex];
			str = elt.text || elt.innerText || elt.textContent;
			str = str.replace(/^[\s]+/, '').replace(/[\s]+$/, '');
			searchFrm.SUBTOPIC_NAME.value = str;
		}
		searchFrm.subTopicType.value = '0';
		var topicVal = commonVariables.topicTree;
		if (selectedTopicIndex > 0) {
			topicVal = commonVariables.getSubtopic(topicVal, selectedTopicIndex-1);
			if (selectedSubTopicIndex > 0) {
				topicVal = commonVariables.getSubtopic(topicVal, selectedSubTopicIndex-1);
				searchFrm.subTopicType.value = topicVal.topicType;
			}
		}
	}

	var searchStr = searchFrm.searchString.value;
	searchStr = replaceSpecialChars(searchStr);
	searchFrm.searchString.value = searchStr;
	if (expandAndValidate(searchStr)) {
		searchFrm.BOOL_SEARCHSTRING.value = expandedStr;
		searchFrm.KEYWORDS.value = keywords.replace(/ /g, "$");
		return true;
	} else {
		alert(L10N_INVALID_SEARCH_STRING);
		return false;
	}

	return true;
}

function addCriteria(searchButton, removeCr) {
var advSearchFrm = document.getElementById("advanceSearchForm");
	if (attribList.length > 0) {

		var selectedAttributeIndex = advSearchFrm.attributes.selectedIndex;
		var selectedOperatorIndex = advSearchFrm.operators.selectedIndex;
		var selectedAndOrIndex = advSearchFrm.andOr.selectedIndex;

		var selectedAttributeValue = advSearchFrm.attributes.options[selectedAttributeIndex].value;
		var selectedAttributeText = advSearchFrm.attributes.options[selectedAttributeIndex].text;
		var selectedOperatorValue = advSearchFrm.operators.options[selectedOperatorIndex].value;
		var selectedOperatorText = advSearchFrm.operators.options[selectedOperatorIndex].text;

		// Perform necessary HTML escape for "<" operator 
		selectedOperatorText = selectedOperatorText.replace(/</g,"&lt;");
		var andOr = advSearchFrm.andOr.options[selectedAndOrIndex].value;
		var andOrText = advSearchFrm.andOr.options[selectedAndOrIndex].text;

		var val = advSearchFrm.val.value;
		advSearchFrm.val.value = "";

		if (val.length < 1) {
			if (numRows<2) {
				alert(L10N_BLANK_SEARCH_STRING);
			} else {
				alert(L10N_ADD_CRITERIA_PROMPT);
			}
			return false;
		}

		// If the attribute selected is of date type, then validate the input string
		if (selectedAttributeIndex >= 0) {
			var selectedAttrib = attribList[selectedAttributeIndex];
			if (selectedAttrib.operatorType == "date") {
				if (!dateValidate(val, true)) {
					advSearchFrm.val.value = val;
					return false;
				}
				val = val.replace(/-/g,"/");
			}
			if (selectedAttrib.operatorType == "int") {
				if (isNaN(val)) {
					return false;
				}
			}
		}

		cr = new Object();
		cr.attribute = selectedAttributeValue;
		cr.operator = selectedOperatorValue;
		cr.andOr = andOr;
		cr.val = val;

		var crTable = document.getElementById('criterionTable1');

		if (numRows>1)
			crTable.deleteRow(numRows-1);

		var newRow = crTable.insertRow(crTable.rows.length);
		numRows++;
		newRow.id = 'criteriaRow'+len;

		var cell0 = newRow.insertCell(0);
		cell0.className="AdvancedCriteriaFirstDataColumn";
		cell0.style.width="16%";
		cell0.id = 'criteria#'+len+'1';
		cell0.value = selectedAttributeText;
		cell0.innerHTML = ''+selectedAttributeText;

		var cell1 = newRow.insertCell(1);
		cell1.className="AdvancedCriteriaDataColumn";
		cell1.style.width="30%";
		cell1.id = 'criteria#'+len+'2';
		cell1.value = selectedOperatorText;
		cell1.innerHTML = '&nbsp;'+selectedOperatorText;

		var cell2 = newRow.insertCell(2);
		cell2.className="AdvancedCriteriaDataColumn";
		cell2.id = 'criteria#'+len+'3';
		cell2.style.width="22%";
		cell2.value = val;
		cell2.innerHTML = '&nbsp;'+val;

		var cell3 = newRow.insertCell(3);
		cell3.className="AdvancedCriteriaLastDataColumn";
		cell3.style.width="5%";
		cell3.id = 'criteria#'+len+'4';
		cell3.value = andOrText;
		cell3.innerHTML = '&nbsp;'+andOrText;

		var cell4 = newRow.insertCell(4);
		cell4.className="AdvancedCriteriaButtonColumn";
		cell4.style.width="13%";
		cell4.innerHTML = "<button type='button' class='ButtonClass2' value='Remove' onclick='removeCriteria("+len+")'>"+removeCr+"</button>";
		cell4.style.align ="right"

		var newCriteriaInput = new Object();
		newCriteriaInput.selectedAttributeIndex = selectedAttributeIndex;
		newCriteriaInput.selectedOperatorIndex = selectedOperatorIndex;
		newCriteriaInput.selectedAndOrIndex = selectedAndOrIndex;
		newCriteriaInput.val = val;
		userInputList[len] = newCriteriaInput;

		crList[len++] = cr;

		var lastRow=crTable.insertRow(crTable.rows.length);
		if (numRows == 2)
			numRows++;

		var newCell = lastRow.insertCell(0);
		newCell.className="AdvancedCriteriaButtonColumn";
		newCell.innerHTML = "<button type='button' class='ButtonClass' value='Go!' onclick=\"advancedSearchSubmit()\" style='width:100px;' >"+searchButton+"!</button>";

		var cell;
		for (i=1;i<5;i++) {
			cell = lastRow.insertCell(i);
		}

		// Change classes so properly update last row (for bottom border)
		for (rowNum=0; rowNum<len; rowNum++) {
			var row = document.getElementById("criteriaRow"+rowNum);
			if (row=="[object]" || row=="[object HTMLTableRowElement]") {
				lastRow = row;
				row.className='';
			}
		}

		if (lastRow=="[object]" || lastRow=="[object HTMLTableRowElement]") {
			lastRow.className = "lastRow";
		}
	} else {
		alert(L10N_NO_ADV_SEARCH_ATTRIBS);
	}
}

function removeCriteria(ID) {
	var toDelete=0;
	var crTable = document.getElementById('criterionTable1');
	
	for (i=0;i<ID;i++) {
		if (crList[i] != "deleted")
			toDelete++;
	}
	
	crTable.deleteRow(toDelete+1);
	crList[ID] = "deleted";
	userInputList[ID] = "deleted";
	numRows = numRows - 1;
	
	if (numRows == 2) {
		crTable.deleteRow(1);
		numRows = numRows-1;
	}

	var lastRow;

	// Change classes so properly update last row (for bottom border)
	for (rowNum=0; rowNum<len; rowNum++) {
		var row = document.getElementById("criteriaRow"+rowNum);
		if (row=="[object]" || row=="[object HTMLTableRowElement]") {
			lastRow = row;
			row.className='';
		}
	}
	
	if (lastRow=="[object]" || lastRow=="[object HTMLTableRowElement]") {
		lastRow.className = "lastRow";
	}
}

function submitFormUsingDropDown(cmdVal) {
	var sideLinkFrm = getForm('ssForm');
	
	var sideLinksTopic = document.getElementById('SIDE_LINKS_TOPIC');
	var selectedTopic = -1;
	if(sideLinksTopic.selectedIndex > -1) {
		sideLinksTopic.options[sideLinksTopic.selectedIndex].value;
	}
	
	var sideLinksSubtopic = document.getElementById('SIDE_LINKS_SUBTOPIC');
	var selectedSubtopic = -1;
	if(sideLinksSubtopic.selectedIndex > -1) {
		selectedSubtopic = sideLinksSubtopic.options[sideLinksSubtopic.selectedIndex].value;
	}

	setFormValue(sideLinkFrm, 'SIDE_LINK_TOPIC_INDEX', sideLinksTopic.selectedIndex);
	setFormValue(sideLinkFrm, 'SIDE_LINK_SUB_TOPIC_INDEX', sideLinksSubtopic.selectedIndex);
	setFormValue(sideLinkFrm, 'SIDE_LINK_TOPIC_ID', document.getElementById('SIDE_LINKS_TOPIC').value);
	setFormValue(sideLinkFrm, 'SIDE_LINK_SUB_TOPIC_ID', document.getElementById('SIDE_LINKS_SUBTOPIC').value);

	var topicTreeNode = commonVariables.topicTree;
	var parentTopic = commonVariables.topicTree;
	if (selectedTopic > -1 && sideLinksTopic.selectedIndex > 0) {
		topicTreeNode = commonVariables.topicTree.subtopics[selectedTopic];
	}
	if (selectedSubtopic > -1 && sideLinksSubtopic.selectedIndex > 0) {
		parentTopic = topicTreeNode;
		topicTreeNode = topicTreeNode.subtopics[selectedSubtopic];
	}

	setFormValue(sideLinkFrm, 'TOPIC_ID', (topicTreeNode ? topicTreeNode.topicId : -1));
	setFormValue(sideLinkFrm, 'TOPIC_TYPE', (topicTreeNode ? topicTreeNode.topicType : 0));
	setFormValue(sideLinkFrm, 'TOPIC_NAME', (topicTreeNode ? topicTreeNode.topicName : L10N_SELECT_ALL_TOPICS));
	setFormValue(sideLinkFrm, 'STARTING_ID', (topicTreeNode ? topicTreeNode.startingId : 0));
	setFormValue(sideLinkFrm, 'PARENT_TOPIC_ID', parentTopic.topicId);
	setFormValue(sideLinkFrm, 'PARENT_TOPIC_NAME', parentTopic.topicName);
	setFormValue(sideLinkFrm, 'PARENT_TOPIC_TYPE', parentTopic.topicType);
	setFormValue(sideLinkFrm, 'SUB_TOPIC_ID', -1);

	markTopicExpanded(parentTopic.topicId);

	return submitSSForm(sideLinkFrm, cmdVal);
}

function go() {
	var searchFrm = document.getElementById("advanceSearchForm");
	try{

		var selectedTopicIndex = searchFrm.TOPIC.selectedIndex;
		var selectedSubTopicIndex = searchFrm.SUBTOPIC.selectedIndex;
		searchFrm.SIDE_LINK_TOPIC_ID.value = searchFrm.TOPIC.options[selectedTopicIndex].value;
		searchFrm.SIDE_LINK_SUB_TOPIC_ID.value = searchFrm.SUBTOPIC.options[selectedSubTopicIndex].value;
	}
	catch(exception) {
		// Done to handle the case when the topic drop-down is disabled in the configuration
	}
	var criterion = "";
	var userInputStr = "";
	var keywords = "";
	for (i=0;i<len;i++) {
		if (crList[i] != "deleted") {
			var attributeName = crList[i].attribute;
			if (attributeName.indexOf("all_attributes")>0) {
				var attr;
				var ops;
				
				// Start the loop from 1 to avoid all attributes which have been deliberately
				// put in the first place of attribute array
				for (k=1;k<attribList.length;k++) {
					var cr = '';
					var isValidDate = true;
					var isValidNum = true;

					attr = attribList[k];
					var opType = attr.operatorType;
					cr = cr + attr.objectName + "#" + attr.attribName + "#" + opType + "#";
					crList[i].val = replaceSpecialChars(crList[i].val);
					if (opType == "date" || opType == "int") {
						ops = operatorMap[opType];
						cr = cr + ops[0];
						
						// Validate the input search string for valid date format if opType is date.
						if (opType == "date") {
							isValidDate = dateValidate(crList[i].val, false);
						}
						if (opType == "int") {
							if (isNaN(crList[i].val))
								isValidNum = false;
						}
					} else {
						cr = cr + crList[i].operator;
					}
					cr = cr + "#" + crList[i].val + "#";
					if (k == (attribList.length-1))
						cr = cr + crList[i].andOr.toLowerCase() + "$";
					else
						cr = cr + "or" + "$";

					if (isValidDate && isValidNum)
						criterion += cr;
				}
			} else {
				criterion = criterion + crList[i].attribute + "#" +
					crList[i].operator + "#" + replaceSpecialChars(crList[i].val) + "#" + crList[i].andOr.toLowerCase() + "$";
			}
			keywords += replaceSpecialChars(crList[i].val) + "$";
		}

		if (userInputList[i] != "deleted") {
			userInputStr = userInputStr + userInputList[i].selectedAttributeIndex + ':' +userInputList[i].selectedOperatorIndex
			+ ':' +userInputList[i].selectedAndOrIndex + ':' +replaceSpecialChars(userInputList[i].val) + '#';
		}

	}

	if (searchFrm.TOPIC) {
		var selectedTopicIndex = searchFrm.TOPIC.selectedIndex;
		var selectedSubTopicIndex = searchFrm.SUBTOPIC.selectedIndex;
		searchFrm.TOPIC_NAME.value = '';
		searchFrm.SUBTOPIC_NAME.value = '';
		searchFrm.subTopicType.value = '0';
		var topicVal = commonVariables.topicTree;
		if (selectedTopicIndex > 0) {
			topicVal = commonVariables.getSubtopic(topicVal, selectedTopicIndex-1);
			searchFrm.TOPIC_NAME.value = topicVal.topicName;
			if (selectedSubTopicIndex > 0) {
				topicVal = commonVariables.getSubtopic(topicVal, selectedSubTopicIndex-1);
				searchFrm.SUBTOPIC_NAME.value = topicVal.topicName;
				searchFrm.subTopicType.value = topicVal.topicType;
			}
		}
	}
	
	searchFrm.criterion.value = criterion;
	searchFrm.KEYWORDS.value = keywords.replace(/ /g, "$");
	searchFrm.userInput.value = userInputStr;
	return true;
}

function populateOperators(operator, externalizedOperator) {
	operators[operators.length] = operator;
	externalizedOperators[operator] = externalizedOperator;
}

function populateOperatorMap(operatorType) {
	operatorMap[operatorType] = operators;
	operators = new Array();
}

function populateAttribList(objectName, attribName, operatorType) {
	attrib = new Object();
	attrib.objectName = objectName;
	attrib.attribName = attribName;
	attrib.operatorType = operatorType;
	attribList[attribList.length] = attrib;
}

function onAttributeChange() {
	var searchFrm = document.getElementById("advanceSearchForm");
	if (attribList.length > 0) {
		var selectedAttribIndex = searchFrm.attributes.selectedIndex;
		var operatorType = attribList[selectedAttribIndex].operatorType;
		var operators = operatorMap[operatorType];
		var len = operators.length;
		searchFrm.operators.options.length = len;
		for (i=0;i<len;i++) {
			searchFrm.operators.options[i].value = operators[i];
			searchFrm.operators.options[i].text = externalizedOperators[operators[i]];
		}
	}
}

var previousValue = '';
function NSonKeyDown(e) {
	var ID = e.target.id;
	if (ID.indexOf("criteria#") > -1) {
		var code = e.which;
		if (code != 37 && code != 39) {
			document.addButton.handleEvent(e);
		}
	}
}

function storeValue(e) {
	if (e.target) {
		previousValue = e.target.value;
	}
}

function reprint(e) {
	if (e.target) {
		if (e.which != 37 && e.which != 39 && e.which != 9)
			e.target.value = previousValue;
	}
}

// This function is for date validation
function dateValidate(str, toShowAlertsOrNot) {
	if (str.length != 8 && str.length != 9 && str.length != 10) {
		if (toShowAlertsOrNot)
			alert(L10N_INVALID_DATE_FORMAT);
		return false;
	}

	if (str.length == 8) {
		var delim1 = str.charAt(1);
		var delim2 = str.charAt(3);
		if (delim1 != delim2) {
			if (toShowAlertsOrNot)
				alert(L10N_INVALID_DATE_FORMAT);
			return false;
		}
		if (delim1 != '/' && delim1 != '-') {
			if (toShowAlertsOrNot)
				alert(L10N_INVALID_DATE_FORMAT);
			return false;
		}
		var monthStr = str.substring(0,1);
		var month = parseInt(monthStr, 10);
		var dayStr = str.substring(2,3);
		var day = parseInt(dayStr, 10);
		var yearStr = str.substring(4,8);
		var year = parseInt(yearStr, 10);
	}

	if (str.length == 9) {
		var delim1 = str.charAt(1);
		var delim2 = str.charAt(2);
		var delim3 = str.charAt(4);
		if ((delim1 != delim3) && (delim2 != delim3)) {
			if (toShowAlertsOrNot)
				alert(L10N_INVALID_DATE_FORMAT);
			return false;
		}
		if (delim3 != '/' && delim3 != '-') {
			if (toShowAlertsOrNot)
				alert(L10N_INVALID_DATE_FORMAT);
			return false;
		}

		// Date format m-dd-yyyy or m/dd/yyyy
		if (delim1 == delim3) {
			var monthStr = str.substring(0,1);
			var month = parseInt(monthStr, 10);
			var dayStr = str.substring(2,4);
			var day = parseInt(dayStr, 10);
			var yearStr = str.substring(5,9);
			var year = parseInt(yearStr, 10);
		}
		// Date format mm-d-yyyy or mm/d/yyyy
		if (delim2 == delim3) {
			var monthStr = str.substring(0,2);
			var month = parseInt(monthStr, 10);
			var dayStr = str.substring(3,4);
			var day = parseInt(dayStr, 10);
			var yearStr = str.substring(5,9);
			var year = parseInt(yearStr, 10);
		}
	}

	if (str.length == 10) {
		var delim1 = str.charAt(2);
		var delim2 = str.charAt(5);
		if (delim1 != delim2) {
			if (toShowAlertsOrNot)
				alert(L10N_INVALID_DATE_FORMAT);
			return false;
		} else {
			if (delim1 != '/' && delim1 != '-') {
				if (toShowAlertsOrNot)
					alert(L10N_INVALID_DATE_FORMAT);
				return false;
			}
		}
		var monthStr = str.substring(0,2);
		var month = parseInt(monthStr, 10);
		var dayStr = str.substring(3,5);
		var day = parseInt(dayStr, 10);
		var yearStr = str.substring(6,10);
		var year = parseInt(yearStr, 10);
	}

	if (isNaN(month) || isNaN(day) || isNaN(year)) {
		if (toShowAlertsOrNot)
			alert(L10N_INVALID_DATE_FORMAT);
		return false;
	}
	if (month > 12 || month < 1) {
		if (toShowAlertsOrNot)
			alert(L10N_MONTH_VALUE_OUT_OF_RANGE);
		return false;
	}
	if (year < 1754 || year > 9998) {
		if (toShowAlertsOrNot)
			alert(L10N_YEAR_VALUE_OUT_OF_RANGE);
		return false;
	}
	if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {
		if (day < 1 || day > 31) {
			if (toShowAlertsOrNot)
				alert(L10N_DAY_VALUE_OUT_OF_RANGE);
			return false;
		}
	} else if (month == 4 || month == 6 || month == 9 || month == 11) {
		if (day < 1 || day > 30) {
			if (toShowAlertsOrNot)
				alert(L10N_DAY_VALUE_OUT_OF_RANGE_THIRTY);
			return false;
		}
	} else if (month == 2) {
		if ((year % 4) != 0 && (day > 28 || day < 1)) {
			if (toShowAlertsOrNot)
				alert(L10N_DAY_VALUE_OUT_OF_RANGE_NON_LEAP_YR);
			return false;
		} else if (day > 29 || day < 1) {
			if (toShowAlertsOrNot)
				alert(L10N_DAY_VALUE_OUT_OF_RANGE_LEAP_YR);
			return false;
		}
	}
	return true;
}

// Stack of tokens as found in search input, in addition, AND operator at required positions
var _tokens = new Array();

function validateExp(exp) {
	try {
		var retValue = eval(exp);
		return true;
	}
	catch(exception ) {
		return false;
	}
}

/**
 * Utility method to check if a give string is a boolean operator used in search strings -
 * and/or/not
 * 
 * @param a
 *            string
 * @return boolean
 */
function isOperator(str) {
	return (str.toLowerCase()=='and' || str.toLowerCase()=='not' || str.toLowerCase()=='or');
}

/**
 * Utility method to check if a give char is parenthesis
 * 
 * @param a
 *            string
 * @return boolean
 */
function isParenthesis(str) {
	return (str=='(' || str==')');
}

function isPhrase(str) {
	return (str.charAt(0) == '"');
}

/**
 * Inserts an OR operator in the token stack at the appropriate location. Called when an expression
 * i.e. non operator token is found in search input string
 */
function insertOr() {
	var keepPopping = true;
	var count = 0;
	var poppedTokens = new Array();
	var sz = _tokens.length;
	if (sz==0)
		return;

	while(keepPopping && count<sz) {
		poppedTokens[count] = _tokens[sz-count-1];

		if (poppedTokens[count]!='(')
			keepPopping = false;
		count++;

	}
	if (!keepPopping) {
		// check last popped token
		var lastPoppedToken = poppedTokens[count-1]
		if (lastPoppedToken==')' || (lastPoppedToken.toLowerCase()!='and' && lastPoppedToken.toLowerCase()!='or' && lastPoppedToken.toLowerCase()!='not')) {
			_tokens[sz-count+1] = 'and';
			for (j=1;j<count;j++)
				_tokens[sz-count+1+j] = poppedTokens[count-j-1]
		}
	}
}

/**
 * Pushes a token into Token stack
 */
function pushToken(currentToken) {
	_tokens[_tokens.length] = currentToken;
}

/**
 * Populates the stack of token by parsing input string. AND operator is pushed if operator missing
 * between to expressions
 */
function populateTokenStack(exp) {
	_tokens = new Array();
	var size = exp.length;
	var retExp = '';
	var inQuotedToken = false;
	var tokenEnded = false;
	var wasQuotedToken = false;
	var currentToken = '';
	var lastToken = '';
	for (i=0;i<size;i++) {
		ch = exp.charAt(i);

		if (ch=='"') {
			tokenEnded = true;
			if (inQuotedToken) {
				inQuotedToken = false;
				wasQuotedToken = true;
			} else {
				inQuotedToken = true;
			}
		} else if (isParenthesis(ch) || ch==' ') {
			if (inQuotedToken) {
				currentToken=currentToken+ch;
			} else {
				tokenEnded = true;
			}
		} else {
			currentToken=currentToken+ch;
		}

		if (tokenEnded) {
			if (currentToken.length>0 && currentToken!= ' ') {
				if (!isOperator(currentToken)) {
					populateKeywords(currentToken);
					insertOr();
				}
				if (wasQuotedToken) {
					currentToken = '"' + currentToken + '"';
					wasQuotedToken = false;
				}
				pushToken(currentToken);
			}
			if (ch=='(' || ch==')')
				pushToken(ch);

			currentToken = '';
			tokenEnded=false;
		}

		if (ch!='"')
			retExp= retExp+ ch;
	}

	lastToken = currentToken;
	if (currentToken.length>0 && currentToken!= ' ') {
		if (!isOperator(currentToken)) {
			populateKeywords(currentToken);
			insertOr();
		}

		pushToken(currentToken);
	}
	currentToken = '';
	return _tokens;
}

function expandAndValidate(exp) {
	var tokens = populateTokenStack(exp);
	var booleanStr ='';
	expandedStr = '';
	var sz = tokens.length;
	for (i=0;i<sz;i++) {
		var token = tokens[i];
		if (isOperator(token)) {
			booleanStr = booleanStr + ' && ';
			if (token.toLowerCase() == 'not') {
				expandedStr = expandedStr + ' ' + 'and ' + token.toLowerCase() + ' ';
			} else {
				expandedStr = expandedStr + ' '+ token.toLowerCase() + ' ';
			}
		} else if (isParenthesis(token)) {
			booleanStr = booleanStr + token;
			expandedStr = expandedStr + ' '+ token + ' ';
		} else {
			booleanStr = booleanStr + ' true ';
			if (isPhrase(token)) {
				expandedStr = expandedStr + ' &wtquote;' + token + '&wtquote; ';
			} else {
				// Add an encoded string as suffix and prefix to tokens
				// that are none phrases.
				// These suffix, prefix will be converted to double quote for
				// ntext column and removed for other column types
				expandedStr = expandedStr + ' &wtquote;' + token + '&wtquote; ';
			}
		}
	}
	if(isOracleDB)
		return validateExp(booleanStr);
	else
		return true;
}

function searchSpellCorrectStr(searchString) {
	var searchFrm = document.getElementById("searchForm");
	searchFrm.searchString.value = searchString;
	return basicSearchSubmit();
}

function populateKeywords(keyword) {
	if (keywords.length == 0)
		keywords += keyword;
	else
		keywords += "$" + keyword;
}

var userInputStr;

function setUserInputStr(input) {
	userInputStr = input;
}

function simulateButtonClicks(searchButton, removeCr) {
	var searchFrm = document.getElementById("advanceSearchForm");
	if (!_isLoaded)
		setTimeout("simulateButtonClicks(" + "'" + searchButton + "', '" + removeCr + "')", 100);
	else {
		if (userInputStr!=null && userInputStr!= 'undefined') {
			var criterions = userInputStr.split('#');
			if (criterions != null && typeof(criterions) != 'undefined') {

				for (var i=0; i<criterions.length; i++) {
					var cr = criterions[i];
					var attribArray = cr.split(":");
					if (attribArray!=null && typeof(attribArray)!= 'undefined')
						if ((attribArray[0] != '' && attribArray[1] != '' && attribArray[2] != '' && attribArray[3] != '')
							&&(typeof(attribArray[0]) != 'undefined' && typeof(attribArray[1]) != 'undefined' && typeof(attribArray[2]) != 'undefined' && typeof(attribArray[3])!= 'undefined')) {

							searchFrm.attributes.selectedIndex = attribArray[0];
							onAttributeChange();
							searchFrm.operators.selectedIndex = attribArray[1];
							searchFrm.andOr.selectedIndex = attribArray[2];
							searchFrm.val.value = attribArray[3];

							addCriteria(searchButton,removeCr);
						}
					searchFrm.attributes.selectedIndex = 0;
					onAttributeChange();
					searchFrm.operators.selectedIndex = 0;
					searchFrm.andOr.selectedIndex = 0;
					searchFrm.val.value = "";
				}
			}
		}
	}
}
