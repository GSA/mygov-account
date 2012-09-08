/* $version_start$ 21/04/2009$eGainBlue$1.0 $version_end$ */
/**
 * Javascript functions used in all the templates
 */

function getForm(form)
{
	return typeof (form) == 'string' ? document.getElementById(form) : form;
}

function getFormElement(form, name)
{
	return getForm(form).elements[name];
}

function getFormValue(form, name)
{
	return getFormElement(form, name).value;
}

// Set value of the named input in the specified form (create the element if
// necessary)
function setFormValue(form, inputName, value)
{
	if (false)
		alert(form + ' ' + inputName + ' ' + value)

	form = getForm(form);
	if (getFormElement(form, inputName) != null)
	{
		getFormElement(form, inputName).setAttribute('value', value);
		getFormElement(form, inputName).value = value;
		return;
	}

	/*
	 * Create and initialize a hidden input, and use browser sniffing to determine if IE (required
	 * to work around IE bugs) See
	 * http://webbugtrack.blogspot.com/2007/10/bug-235-createelement-is-broken-in-ie.html for more
	 * information.
	 */
	var isIE = navigator.userAgent.indexOf('MSIE') >= 0;
	var input = null;
	if (!isIE)
	{
		input = document.createElement('input');
		input.setAttribute('name', inputName);
	}
	else
	{
		input = document.createElement('<input name="' + inputName + '" />');
	}
	input.setAttribute('type', 'hidden');
	input.setAttribute('value', value);
	input.value = value;
	try
	{
		form.appendChild(input);
	}
	catch (e)
	{
		alert("Error : setFormValue -" + e.message);
	}
}

function submitSSForm(form, command, formAction, method, target)
{
	if (false)
	{
		// Debug: enable to use the link href rather than the onclick handler
		if (window.event && window.event.srcElement && window.event.srcElement.tagName.toLowerCase() == 'a')
			return true;
	}

	var form = getForm(form);
	setFormValue(form, 'CONFIGURATION', commonVariables.configurationId);
	setFormValue(form, 'PARTITION_ID', commonVariables.partitionId);
	setFormValue(form, 'EXPANDED_TOPIC_TREE_NODES', getFormValue('ssForm', 'EXPANDED_TOPIC_TREE_NODES'));
	setFormValue(form, 'TIMEZONE_OFFSET', commonVariables.timezoneOffset);
	if (command)
		setFormValue(form, 'CMD', command);
	if (formAction)
		form.action = formAction;
	if (!form.action)
		form.action = commonVariables.formAction;
	if (method)
		form.method = method;
	else
		form.method = commonVariables.submissionMethod;
	if (target)
		form.target = target;

	// Debugging only
	if (false)
	{
		alert(form.id + ' ' + form.action + ' ' + getFormValue(form, 'CMD'));
		for ( var i = 0; i < form.elements.length; i++)
		{
			alert(form.elements[i].name + ' ' + form.elements[i].value);
		}
	}

	form.submit();

	// Prevent the default action if the handler is on a link or button etc.
	return false;
}

function submitOnReturn(evt, form)
{
	if (window.event && window.event.keyCode == 13 || evt.which == 13)
		submitSSForm(form);
}

function startGuidedHelp()
{
	var form = getForm('ssForm');
	setFormValue(form, 'CMD', 'iLogon');
	setFormValue(form, 'GCL', 'Yes');
	setFormValue(form, 'LG', 1);
	return submitSSForm(form);
}

function executeLink(linkName, linkId, linkType)
{
	var linkFrm = getForm("linkOptions");
	setFormValue(linkFrm, 'LINK_ID', linkId);
	setFormValue(linkFrm, 'LINK_TYPE', linkType);
	setFormValue(linkFrm, 'LINK_NAME', linkName);
	return submitSSForm(linkFrm);
}

function executeCascadedLink(row, col)
{
	eval("document.cascade_" + row + "_" + col + ".submit()");
}

function validateAndExecuteLink()
{
	var inputs = new Array();
	var size = document.linkInputOptions.elements.length;
	var count = 0;
	for ( var i = 0; i < size; i++)
	{
		var name = document.linkInputOptions.elements[i].name;
		if (name.indexOf("inputKey_") != -1 && name.indexOf(".key") != -1 && !(name.indexOf(".keyType") != -1))
		{
			var underscoreIndex = name.indexOf("_");
			var dotIndex = name.indexOf(".");
			var keyIndex = name.substring(underscoreIndex + 1, dotIndex);
			if (name.indexOf(".keyName") != -1)
			{
				if (typeof inputs[keyIndex] == "undefined")
					inputs[keyIndex] = new Object();
				inputs[keyIndex].name = document.linkInputOptions.elements[i].value;
			}
			else if (name.indexOf(".keyValue") != -1)
			{
				if (typeof inputs[keyIndex] == "undefined")
					inputs[keyIndex] = new Object();
				inputs[keyIndex].value = document.linkInputOptions.elements[i].value;
			}
		}
	}

	for (i = 0; i < inputs.length; i++)
	{
		var value = inputs[i].value;
		if (value == "")
		{
			alert(L10N_DATAADAPTOR_ENTRY_PROMPT_PREFIX + inputs[i].name);
			return false;
		}
	}

	document.linkInputOptions.submit();
	return true;
}

// Create event handler for window close
function closewindow()
{
	try
	{
		if (document.all)
		{
			var windowName = window.name;
			if ((window.screenTop > 10000 || (window.event.clientX < -5000) || (window.event.clientY < -5000))
							&& windowName != 'attachment' && windowName.indexOf('ArticleDetails') < 0
							&& window.name != 'PrintArticle')
			{
				// Auto-logoff
				submitSSForm('ssForm', 'LOGOFF');
			}
		}
	}
	catch (e)
	{
	}
}

// Firefox does not pick up the following variables from util.js, so redefine here
var IDENTIFIER_START = "\\{";
var IDENTIFIER_END = "\\}";

function getFormattedMessage(msgStr, dynamicValues)
{
	var retVal = msgStr;

	try
	{
		if (typeof dynamicValues != "undefined" && dynamicValues != null)
		{
			var size = dynamicValues.length;
			for ( var i = 0; i < size; i++)
			{
				retVal = retVal.replace(new RegExp(IDENTIFIER_START + i + IDENTIFIER_END, "g"), dynamicValues[i]);
			}
		}
	}
	catch (e)
	{
		alert(e.message);
	}

	return retVal;
}

// Assign event handler
window.onunload = closewindow;

function loadL10NFile(file, language, country, application)
{
	language = language | commonVariables.language;
	country = country | commonVariables.country;

	var fileURL = file.replace(/\\/, "/").replace(/\/\//, "/");

	if (language && language != "undefined" && language != "" && language != "en")
		fileURL = fileURL.replace('/en/', '/' + language + '/');

	if (country && country != "undefined" && country != "" && country.indexOf("_") != -1)
		country = (country.split("_"))[1];

	if (country && country != "undefined" && country != "" && country != "us")
		fileURL = fileURL.replace('/us/', '/' + country + '/');

	if (application && application != "undefined" && application != "" && application != "pl")
		fileURL = fileURL.replace('/pl/', '/' + application + '/');

	loadScriptFile(fileURL)
}

function loadScriptFile(fileURL)
{
	var element = document.createElement('script')
	try
	{
		document.getElementsByTagName('HEAD')[0].appendChild(element);
	}
	catch (e)
	{
		alert("Error : loadScriptFile - " + e.message);
	}
	element.src = fileURL;
}

function trim(str)
{
	return str.replace(/^\s\s*/, '').replace(/\s\s*$/, '');
}

function getTreeTrain()
{
	var maketree = getForm("maketree");
	var replace = maketree.elements['treeretain'].value;
	var intIndexOfMatch = replace.indexOf("*");
	while (intIndexOfMatch != -1)
	{
		replace = replace.replace("*", "\"");
		intIndexOfMatch = replace.indexOf("*");
	}
	var intIndexOfMatch2 = replace.indexOf("^");
	while (intIndexOfMatch2 != -1)
	{
		replace = replace.replace("^", "\&nbsp\;")
		intIndexOfMatch2 = replace.indexOf("^");
	}
	return replace;
}

function removeArticleFromFavorites(configId, articleId)
{
	// Confirm deletion of favorite
	if (confirm(L10N_DELETE_FAVORITE_CONFIRM))
	{
		var iFavCount = readCookie('favoritefaqcount');
		var favs = new Array(iFavCount);
		var removal = "|" + articleId;
		var count = 1;
		for (i = 1; i <= iFavCount; i++)
		{
			favs[i - 1] = readCookie('favoritefaq' + i);
		}
		document.cookie = "";
		for (i = 1; i <= iFavCount; i++)
		{
			if (favs[i - 1].indexOf(removal) >= 0)
				continue;
			setCookie('favoritefaq' + count, favs[i - 1]);
			count++;
		}
		setCookie('favoritefaq' + iFavCount, "");
		iFavCount--;
		if (iFavCount < 0)
			iFavCount = 0;
		setCookie('favoritefaqcount', iFavCount);

		// Refresh list of favorites
		submitSSForm('myStuff', 'MY_FAVORITES');
	}
}

function addArticleToFavorites(configId, articleId, articleName)
{
	var arr = new Array();
	arr[0] = articleName;

	if (document.cookie.indexOf(configId + "|" + articleId) == -1)
	{
		var iFavCount = readCookie('favoritefaqcount');
		iFavCount++;
		setCookie('favoritefaqcount', iFavCount);
		setCookie('favoritefaq' + iFavCount, configId + "|" + articleId);
		iFavCount = readCookie('favoritecount');
		alert(getFormattedMessage(L10N_ARTICLE_ADDED_TO_FAVORITES, arr));
	}
	else
	{
		alert(getFormattedMessage(L10N_ARTICLE_ALREADY_ADDED_TO_FAVORITES, arr));
	}
}

function setCookie(name, value, path, domain, secure)
{
	var now = new Date();
	now.setTime(now.getTime() + 365 * 24 * 60 * 60 * 1000);
	var curCookie = name + "=" + value + "; expires=" + now.toGMTString() + ((path) ? "; path=" + path : "")
					+ ((domain) ? "; domain=" + domain : "") + ((secure) ? "; secure" : "");
	document.cookie = curCookie;
}

function readCookie(cookieName)
{
	var theCookie = "" + document.cookie;
	var ind = theCookie.indexOf(cookieName);
	if (ind == -1 || cookieName == "")
		return "";
	var ind1 = theCookie.indexOf(';', ind);
	if (ind1 == -1)
		ind1 = theCookie.length;
	return unescape(theCookie.substring(ind + cookieName.length + 1, ind1));
}

/* Change appearance of row */
function changeRowColor(tableRow, highLight, current)
{
	tableRow.className = current;
	if (highLight)
	{
		tableRow.className += 'hover';
	}
}

/**
 * 
 * Base64 encode / decode http://www.webtoolkit.info/
 * 
 */

var Base64 = {

	// private property
	_keyStr : "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=",

	// public method for encoding
	encode : function(input)
	{
		var output = "";
		var chr1, chr2, chr3, enc1, enc2, enc3, enc4;
		var i = 0;

		input = Base64._utf8_encode(input);

		while (i < input.length)
		{
			chr1 = input.charCodeAt(i++);
			chr2 = input.charCodeAt(i++);
			chr3 = input.charCodeAt(i++);

			enc1 = chr1 >> 2;
			enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
			enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
			enc4 = chr3 & 63;

			if (isNaN(chr2))
			{
				enc3 = enc4 = 64;
			}
			else if (isNaN(chr3))
			{
				enc4 = 64;
			}

			output = output + this._keyStr.charAt(enc1) + this._keyStr.charAt(enc2) + this._keyStr.charAt(enc3)
							+ this._keyStr.charAt(enc4);

		}

		return output;
	},

	// public method for decoding
	decode : function(input)
	{
		var output = "";
		var chr1, chr2, chr3;
		var enc1, enc2, enc3, enc4;
		var i = 0;

		input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");

		while (i < input.length)
		{

			enc1 = this._keyStr.indexOf(input.charAt(i++));
			enc2 = this._keyStr.indexOf(input.charAt(i++));
			enc3 = this._keyStr.indexOf(input.charAt(i++));
			enc4 = this._keyStr.indexOf(input.charAt(i++));

			chr1 = (enc1 << 2) | (enc2 >> 4);
			chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
			chr3 = ((enc3 & 3) << 6) | enc4;

			output = output + String.fromCharCode(chr1);

			if (enc3 != 64)
			{
				output = output + String.fromCharCode(chr2);
			}
			if (enc4 != 64)
			{
				output = output + String.fromCharCode(chr3);
			}

		}

		output = Base64._utf8_decode(output);

		return output;

	},

	// private method for UTF-8 encoding
	_utf8_encode : function(string)
	{
		string = string.replace(/\r\n/g, "\n");
		var utftext = "";

		for ( var n = 0; n < string.length; n++)
		{
			var c = string.charCodeAt(n);

			if (c < 128)
			{
				utftext += String.fromCharCode(c);
			}
			else if ((c > 127) && (c < 2048))
			{
				utftext += String.fromCharCode((c >> 6) | 192);
				utftext += String.fromCharCode((c & 63) | 128);
			}
			else
			{
				utftext += String.fromCharCode((c >> 12) | 224);
				utftext += String.fromCharCode(((c >> 6) & 63) | 128);
				utftext += String.fromCharCode((c & 63) | 128);
			}
		}

		return utftext;
	},

	// private method for UTF-8 decoding
	_utf8_decode : function(utftext)
	{
		var string = "";
		var i = 0;
		var c = c1 = c2 = 0;

		while (i < utftext.length)
		{
			c = utftext.charCodeAt(i);

			if (c < 128)
			{
				string += String.fromCharCode(c);
				i++;
			}
			else if ((c > 191) && (c < 224))
			{
				c2 = utftext.charCodeAt(i + 1);
				string += String.fromCharCode(((c & 31) << 6) | (c2 & 63));
				i += 2;
			}
			else
			{
				c2 = utftext.charCodeAt(i + 1);
				c3 = utftext.charCodeAt(i + 2);
				string += String.fromCharCode(((c & 15) << 12) | ((c2 & 63) << 6) | (c3 & 63));
				i += 3;
			}
		}

		return string;
	}
}

function viewArticle(articleId) {
	if (commonVariables.articlesInNewWindow) {
		//adding a string to maintain a ref. for view article
		var theURL = commonVariables.ssUrl
		+ '&CMD=VIEW_ARTICLE'
		+ '&ARTICLE_ID='+articleId ;
		var windowName = 'ArticleDetails'+ Math.floor(Math.random()*101);
		window.open(theURL, windowName);
		return false;
	}
	else
	{
		setFormValue('ssForm', 'ARTICLE_ID', articleId);
		return submitSSForm('ssForm', 'VIEW_ARTICLE');
	}
}
