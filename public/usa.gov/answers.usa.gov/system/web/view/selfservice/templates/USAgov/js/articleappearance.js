/* $version_start$ 21/04/2009$eGainBlue$1.0 $version_end$ */
/*
 * This file contains the support functions for the articleappearance template.
 */
var childWindows = new Array(100);
var noOfChildren = 0;

$(document).ready(function () {
	// add article URL in article view
	/*
	commonVariables.currentCommand == "VIEW_ARTICLE" &&
	$("h1#title_dl").each(function() {
		var url = " " + location.protocol + "//" + location.host + 
		"/system/viewArticle.jsp?ARTICLE_ID=" + commonVariables.articleId + 
		"&amp;LANGUAGE=" + commonVariables.language +
		"&amp;CONFIGURATION=1000" ;
	$("<div><br><font size=-1 color=red><b>Please use this link in Chats and Email Replies:<br><font color=blue>" + url + "</font></b></font></div>").insertAfter($(this));
	});
	
	$('div.richArticleContent a')
		.attr("target","_blank");
	$("div.articleContent div.ArticleFooter")
		.removeClass("ArticleFooter")
		.addClass("articleOptions");
	*/
});

///////////////////////////////////

/*
--BEGIN toggleBlock FUNCTION--
This function applies to the Article Template for CheckFree
It allows for the toggling of div section visibility within the article
*/
function toggleBlock(id){
	var theDetails = document.getElementById(id);
	var thePlus = document.getElementById(id + "_plus");
	var theMinus = document.getElementById(id + "_minus");
	
	if(theMinus.style.display == ""){
        theMinus.style.display = "none";
        theDetails.style.display = "none";
        thePlus.style.display = "";
	} else {
	    theMinus.style.display = "";
	    theDetails.style.display = "";
	    thePlus.style.display = "none";
	}
}
/*--END toggleBlock FUNCTION--*/

window.onbeforeunload = function()
{
	/* Unload caused because of click in the nonclient area of the window */
	if (document.all && ((window.event.clientX < 0) || (window.event.clientY < 0)))
	{
		/* If this window has no child windows no need to show the warning message */
		if (noOfChildren > 0)
		{
			return L10N_CLOSE_ARTICLE_DETAILS_WINDOW_CONFIRM;
		}
	}
}

// This function addresses the request of opening an attachment.
function showAttachment(attachmentURL, attachmentName, attachmentId, jspPath, use_appserver_key, fileName)
{
	fileName = encodeURIComponent(fileName);
	attachmentURL = eGainEncodeURI(attachmentURL);
	var filePath = jspPath + "showattachment.jsp?articleAttchmentUrl=" + attachmentURL + "&FILE_NAME=" + fileName
					+ "&ART_ATTACHMENT_NAME=" + attachmentName + "&ART_ATTACHMENT_ID=" + attachmentId;

	if (use_appserver_key == "false")
		window.open(filePath);
	else
	{
		try
		{
			document.body.insertAdjacentHTML("beforeEnd",
				'<iframe class="activityDetails1" style="display:none; width:0%; height:0%;" name="fwStaticBuff" id="fwStaticBuff" scrolling="yes"></iframe>');

			if (document.all)
			{
				// IE only
				document.frames['fwStaticBuff'].location.href = filePath;
			}
			else
			{
				// Non-IE
				document.getElementById('fwStaticBuff').src = filePath;
			}
		}
		catch (e)
		{
			alert(e.message);
		}
	}
}

// This function opens a new article for printing .
function printArticle(articleId)
{
	window.open(commonVariables.ssUrl + '&CMD=PRINT_ARTICLE&ARTICLE_ID=' + articleId, 'PrintArticle');
	return false;
}

/*
 * This function checks whether the article is opened in a new window or the same window.
 * If the article is opened in a new window then it checks whether the opener is still alive or not.
 * If the opener is not alive it closes the new window also. 
 */
function checkForOpener()
{
	var windowName = window.name;
	if (windowName.indexOf("ArticleDetails") >= 0)
	{
		try
		{
			var obj = opener.document;
		}
		catch (Error)
		{
			window.close();
		}
	}
}

function emailArticle(articleId)
{
	try
	{
		setFormValue('ssForm', 'ORIGINAL_ARTICLE_ID', articleId);
		return submitSSForm('ssForm', 'EMAIL_ARTICLE');
	}
	catch (e)
	{
		alert(e.message);
	}
}

function closeChildWindows()
{
	var i;
	/*
	 * Don't close the child windows if the unload event was generated because of a click in the
	 * windows client are
	 */
	if (document.all && ((window.event.clientX < 0) || (window.event.clientY < 0)))
	{
		for (i = 0; i < noOfChildren; i++)
		{
			/* Check if the child window is closed earlier */
			if ((childWindows[i] != null) && (!childWindows[i].closed))
			{
				childWindows[i].close();
			}
		}
	}
}

function getRelatedArticle(articleId, articleName, currCMD)
{
    if (!commonVariables.articlesInNewWindow)
	{
		setFormValue('ssForm', 'ARTICLE_ID', articleId);
		setFormValue('ssForm', 'RELATED_ARTICLE_CLICK', 1);
		setFormValue('ssForm', 'RELATED_ARTICLE_NAME', articleName);
		setFormValue('ssForm', 'SOURCE_RELATED_ARTICLE', true);
		return submitSSForm('ssForm', 'VIEW_ARTICLE');
	}

	var theURL = commonVariables.ssUrl + "&CMD=VIEW_ARTICLE&ARTICLE_ID=" + articleId + "&CURRENT_CMD=" + currCMD;
	var windowName = 'ArticleDetails' + Math.floor(Math.random() * 101);
	var newArticleWind = window.open(theURL, windowName);

	/* Add the child window to the array of childwindows spawned from this window */
	childWindows[noOfChildren] = newArticleWind;
	noOfChildren = noOfChildren + 1;

	newArticleWind.focus();
	return false;
}

function addarticletorecentfaq(configId, articleId, articleName)
{
	if (document.cookie.indexOf(configId + "|rr|" + articleId + "|r|" + articleName) == -1)
	{
		var iFavCount = readCookie('recentfaqcount');
		iFavCount++;
		if (iFavCount <= 11)
		{
			setCookie('recentfaqcount', iFavCount);
			setCookie('recentfaq' + iFavCount, configId + "|rr|" + articleId + "|r|" + articleName);
		}
		else
		{
			for ( var i = 1; i < 11; i++)
			{
				setCookie('recentfaq' + i, readCookie('recentfaq' + (i + 1)));
			}
			setCookie('recentfaq' + i, configId + "|rr|" + articleId + "|r|" + articleName);
		}
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

function eGainEncodeURI(url)
{
	var index = url.lastIndexOf('\\');
	if (index == -1)
	{
		return encodeURI(url);
	}
	else
	{
		var mainurl = url.substring(0, index);
		var fileName = url.substring(index + 1, url.length);
		fileName = encodeURIComponent(fileName);
		mainurl += "/" + fileName;
	}
	return mainurl;
}

function sendArticleDataToUAC(formName, command, obj,articleId) {
	document.getElementById("callTrackArticlesUsedFrom").ARTICLE_ID.value = articleId;
	var retVal = 1;

	try {
		retVal = top.callMethod("infoall", "getArticleDataFromWT", obj).value;
	} catch(e) {
	}
	
	if (typeof retVal != 'undefined' && retVal == 0) { 
		// Session expired
		return submitSSForm(formName,command);
	}

	return false;
}

function contentLinkKeyPress(evt) {
	evt = evt || window.event;
	var key = evt.which || evt.keyCode;
	if (key == 13 ) { // enter
		anchor = getTarget(evt);
		anchor.target='_blank';
		return cancelEvent(evt);
	}
}

function contentLinkClick(evt) {
	evt = evt || window.event;
	anchor = getTarget(evt);
	anchor.target='_blank';
}
