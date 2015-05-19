var kansotopbar = require('kanso-topbar');

$(document).ready(function() {
    if (window.location.href.match(/\/_rewrite$/) !== null) location.href += '/';

    $("#player").affix({
        offset: {
            top: 0
        }
    });

    kansotopbar.init();
});

$(window).on('resize', function() {
    var win = $(this); //this = window
    if (win.height() > 700) {
        $("#container").attr("class", "smallheight");
    } else {
        $("#container").attr("class", "");
    }
    $(".col-sm-13").attr("style", "width:" + (win.width() - $(".col-sm-0").width() - 20) + "px");
    $(".jp-playlist").attr("style", "height:" + (win.height() - $(".jp-gui").height() - $(".jp-jplayer").height() - 20) + "px");
});

/*
 *    var splitUrl = document.location.href.split('/');
 *    var designPos = splitUrl.indexOf('_design');
 *    if (designPos > 4) {
 *       var newPrefix = "";
 *       for (var i = 3; i < (designPos - 1); i++) {
 *           newPrefix += "/" + splitUrl[i];
 *       }
 *       $.couch.urlPrefix = newPrefix;
 *   }
 */

$.couch.urlPrefix = ".";
$.couch.app(function(app) {
    var newLoggedOut = app.ddoc.vendor.couchapp.evently.account.loginForm;
    newLoggedOut.after = function(data) {
        var elem = $(this);
        $('#kanso-topbar-login-dropdown form').submit(function(ev) {
            ev.preventDefault();
            var form = this;
            var username = $('input[name="name"]', form).val();
            var password = $('input[name="password"]', form).val();
            elem.trigger('doLogin', [username, password]);
            return false;
        });
    };
    var customAccount = $.extend(true, {}, app.ddoc.vendor.couchapp.evently.account, {
        "loggedIn": {
            "data": function(e, r) {
                kansotopbar.updateSession(r.userCtx);
                var elem = $(this);
                $('#kanso-topbar-session .kanso-topbar-logout a').click(function(ev) {
                    ev.preventDefault();
                    elem.trigger('doLogout');
                    setTimeout(function() {
                        if (window.location.href.match(/\/_rewrite$/) === null) location.href = '/';
                    }, 1000);
                    return false;
                });
                return {
                    /*
                     *name: r.userCtx.name,
                     *uri_name: encodeURIComponent(r.userCtx.name),
                     *auth_db: encodeURIComponent(r.info.authentication_db)
                     */
                };
            },
            "after": function(data) {
                kansotopbar.hideDropDown();
            },
            "mustache": "_"
        },
        "loggedOut": newLoggedOut
    });

    $("#account").evently(customAccount);

    $("#player").evently("player", app);
    $.evently.connect("#account", "#player", ["loggedIn", "loggedOut"]);

    $("#list").evently("list", app);
    $.evently.connect("#account", "#list", ["loggedIn", "loggedOut"]);

    $.evently.connect("#list", "#player", ["play"]);
    $.evently.connect("#player", "#list", ["next", "previous"]);

    $("#searchBox").evently("searchBox", app);
    $.evently.connect("#account", "#searchBox", ["loggedIn", "loggedOut"]);
    $.evently.connect("#searchBox", "#list", ["setList"]);

    $("#libraryTitle").evently("libraryTitle", app);
    $.evently.connect("#account", "#libraryTitle", ["loggedIn", "loggedOut"]);

    $("#page-menu").evently("pageMenu", app);
    $.evently.connect("#account", "#page-menu", ["loggedIn", "loggedOut"]);

}, {
    db: "_db",
    design: "movies"
});

$('#aboutLink').click(function(e) {
    $('#about').fadeIn();
    e.preventDefault();
});

$('#aboutCloseLink').click(function(e) {
    $('#about').fadeOut();
    e.preventDefault();
});
