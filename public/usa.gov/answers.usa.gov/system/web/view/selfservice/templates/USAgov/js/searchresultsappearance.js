/* $version_start$ 21/04/2009$eGainBlue$1.0 $version_end$ */

/*
 * This file contains the support functions for the searchresultsappearance template.
 */
function onBeforeUnload() {
	/* Unload caused because of click in the nonclient area of the window */
	if (document.all && ((window.event.clientX<0) || (window.event.clientY<0))) {
		return L10N_CLOSE_ARTICLE_DETAILS_WINDOW_CONFIRM;
	}
}

// This function addresses the request of ascending order sorting on any attribute.
function sortAsc(attribName) {
	setFormValue('searchResultsForm', 'sortOrder', '1');
	setFormValue('searchResultsForm', 'sortOn', attribName);
	setFormValue('searchResultsForm', 'articlePerPage', commonVariables.articlesPerPage);
	return submitSSForm('searchResultsForm', 'SORT_ARTICLE_LIST');
}

// This function addresses the request of descending order sorting on any attribute.
function sortDesc(attribName) {
	setFormValue('searchResultsForm', 'sortOrder', '0');
	setFormValue('searchResultsForm', 'sortOn', attribName);
	setFormValue('searchResultsForm', 'articlePerPage', commonVariables.articlesPerPage);
	return submitSSForm('searchResultsForm', 'SORT_ARTICLE_LIST');
}

// This function fetches the page corresponding to the page number passed.
function getPage(nextPageNo) {
	setFormValue('searchResultsForm', 'nextPageNo', nextPageNo);
	setFormValue('searchResultsForm', 'articlePerPage', commonVariables.articlesPerPage);
	return submitSSForm('searchResultsForm', 'GET_NEXT_PAGE_RESULTS', null, "POST");
}

// This function fetches the page previous to the current page.
function prevPage() {
	return getPage(commonVariables.currPageNo - 1);
}

// This function fetches the page next to the current page.
function nextPage() {
	return getPage(commonVariables.currPageNo + 1);
}

// This function opens a new article.
function getArticle(articleId, isNewWindow, currCMD) {
	if (isNewWindow == 1) {
		var theURL = commonVariables.ssUrl + "&CMD=VIEW_ARTICLE' + '&ARTICLE_ID=" + articleId + "&CURRENT_CMD=" + currCMD;
		var windowName = 'ArticleDetails'+ Math.floor(Math.random()*101);
		var newArticleWind = window.open(theURL, windowName);
		window.onbeforeunload = onBeforeUnload;
		newArticleWind.focus();
		return false;
	} else {
		window.onbeforeunload = null;
		setFormValue('searchResultsForm', 'ARTICLE_ID', articleId);
		return submitSSForm('searchResultsForm', 'VIEW_ARTICLE', null, "POST");
	}
}

