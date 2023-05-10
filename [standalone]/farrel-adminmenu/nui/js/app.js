FARREL = {}
FARREL.AdminMenu = {}

FARREL.AdminMenu.Action = {}
FARREL.AdminMenu.Category = {}
FARREL.AdminMenu.Sidebar = {}
FARREL.AdminMenu.PlayerList = {}
FARREL.AdminMenu.SizeChange = {}

FARREL.AdminMenu.DebugEnabled = null;
FARREL.AdminMenu.Opened = false;
FARREL.AdminMenu.IsGeneratingDropdown = false;

FARREL.AdminMenu.FavoritedItems = {};
FARREL.AdminMenu.EnabledItems = {};
FARREL.AdminMenu.Bans = [];

FARREL.AdminMenu.Logs = null;
FARREL.AdminMenu.Players = null;
FARREL.AdminMenu.Items = null;
FARREL.AdminMenu.CurrentTarget = null;
FARREL.AdminMenu.Size = "Small";

// Editable

FARREL.AdminMenu.SizeChange.LeftArrow = '<i class="fas fa-chevron-left"></i>'; // Arrow when menu can be changed to large
FARREL.AdminMenu.SizeChange.RightArrow = '<i class="fas fa-chevron-right"></i>'; // Arrow when menu can be changed to small

// Code

FARREL.AdminMenu.Update = function(Data) {
    DebugMessage(`Menu Updating`);
    FARREL.AdminMenu.FavoritedItems = Data.Favorited;
    FARREL.AdminMenu.Players = Data.AllPlayers;
    FARREL.AdminMenu.Items = Data.AdminItems;
    FARREL.AdminMenu.Bans = Data.Bans;
    FARREL.AdminMenu.Logs = Data.Logs;
    if (FARREL.AdminMenu.Sidebar.Selected == 'Actions') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadItems();
    } else if (FARREL.AdminMenu.Sidebar.Selected == 'PlayerLogs') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadPlayerLogs();
    } else if (FARREL.AdminMenu.Sidebar.Selected == 'PlayerList') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadPlayerList();
    }
}
 
FARREL.AdminMenu.Open = function(Data) {
    FARREL.AdminMenu.DebugEnabled = Data.Debug;
    FARREL.AdminMenu.FavoritedItems = Data.Favorited;
    FARREL.AdminMenu.Bans = Data.Bans;
    DebugMessage(`Menu Opening`);
    $('.menu-main-container').css('pointer-events', 'auto');
    $('.menu-main-container').fadeIn(450, function() {
        FARREL.AdminMenu.Logs = Data.Logs;
        FARREL.AdminMenu.Players = Data.AllPlayers
        FARREL.AdminMenu.Items = Data.AdminItems
        $('.menu-pages').find(`[data-Page="${FARREL.AdminMenu.Sidebar.Selected}"`).fadeIn(150);
        FARREL.AdminMenu.LoadCategory(FARREL.AdminMenu.Sidebar.Selected);
        FARREL.AdminMenu.Opened = true;
    });
    if (FARREL.AdminMenu.Sidebar.Selected == 'Actions') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadItems();
    } else if (FARREL.AdminMenu.Sidebar.Selected == 'PlayerLogs') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadPlayerLogs();
    } else if (FARREL.AdminMenu.Sidebar.Selected == 'PlayerList') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadPlayerList();
    }
}


FARREL.AdminMenu.Close = function() {
    DebugMessage(`Menu Closing`);
    FARREL.AdminMenu.ClearDropdown();
    $.post(`https://${GetParentResourceName()}/Admin/Close`);
    $('.menu-main-container').css('pointer-events', 'none');
    $('.menu-main-container').fadeOut(150, function() {
        FARREL.AdminMenu.Opened = false; 
    });
}

FARREL.AdminMenu.ChangeSize = function(ForceSize) {
    let Styles = getComputedStyle(document.body);
    if (ForceSize != null && ForceSize == 'Large' || FARREL.AdminMenu.Size == 'Small' && ForceSize == null) {
        $('.menu-size-change').html(FARREL.AdminMenu.SizeChange.RightArrow);
        FARREL.AdminMenu.Size = 'Large';
        $('.menu-main-container').css({
            width: Styles.getPropertyValue('--menu-large-width'),
            right: 19+"%",
        });
    } else if (ForceSize != null && ForceSize == 'Small' || FARREL.AdminMenu.Size == 'Large' && ForceSize == null) {
        $('.menu-size-change').html(FARREL.AdminMenu.SizeChange.LeftArrow);
        FARREL.AdminMenu.Size = 'Small';
        $('.menu-main-container').css({
            width: Styles.getPropertyValue('--menu-small-width'),
            right: 3+"%",
        });
    }
    setTimeout(() => {
        if (FARREL.AdminMenu.CheckMenuSize('Logs')) {
            FARREL.AdminMenu.BuildPlayerLogs();
        }
    }, 350);
}
FARREL.AdminMenu.CheckMenuSize = function(Type) {
    if (Type == 'Logs') {
        if (FARREL.AdminMenu.Sidebar.Selected == 'PlayerLogs') {
            if (FARREL.AdminMenu.Size == 'Small') {
                if ($(".menu-page-playerlogs-list-search").is(":visible")) {
                    $('.menu-page-playerlogs-list-search').hide();
                }
                if ($(".admin-menu-logs-grid").is(":visible")) {
                    $('.admin-menu-logs-grid').hide();
                }
                $('.logs-availability').fadeIn(450);
                return false
            } else {

                $('.logs-availability').hide();
                $('.menu-page-playerlogs-list-search').fadeIn(250);
                $('.admin-menu-logs-grid').fadeIn(450);
                return true
            }
        }
    }
}
FARREL.AdminMenu.ResetPage = function(Type) {
    if (Type == 'All') {
        $('.menu-page-options-items').hide();
    }
}
FARREL.AdminMenu.Copy = function(Text) {
    let TextArea = document.createElement('textarea');
    let Selection = document.getSelection();
    TextArea.textContent = Text;
    document.body.appendChild(TextArea);
    Selection.removeAllRanges();
    TextArea.select();
    document.execCommand('copy');
    Selection.removeAllRanges();
    document.body.removeChild(TextArea);
}

// [ CLICKS ] \\

$(document).on('click', '.menu-size-change', function(e) {
    e.preventDefault();
    FARREL.AdminMenu.ChangeSize()
});

$(document).on('click', '.menu-current-target', function(e){
    $(this).parent().find('.ui-styles-input').each(function(Elem, Obj){
        if ($(this).find('input').data("PlayerId")) {
            if (FARREL.AdminMenu.CurrentTarget != null) {
                if ($('.admin-menu-item').find('.admin-menu-items-option-input').first().find('.ui-input-label').text() == 'Player') {
                    $(this).find('input').data("PlayerId", null)
                    $(this).find('input').val(" ");
                }
            }
        }
    });
    $('.admin-menu-items').animate({
        'max-height': 72.6+'vh',
    }, 100);
    $('.menu-current-target').fadeOut(150);
    FARREL.AdminMenu.CurrentTarget = null;
});

$(document).on('click', '.ui-styles-checkbox', function(){


    $(this).removeClass('ripple-effect');
    $(this).addClass('ripple-effect');
    setTimeout(() => {
        $(this).removeClass('ripple-effect');
    }, 500);
});


// [ FUNCTIONS ] \\

DebugMessage = function(Message) {
    if (FARREL.AdminMenu.DebugEnabled) {
        console.log(`[DEBUG]: ${Message}`);
    }
}

// [ LISTENER ] \\

document.addEventListener('DOMContentLoaded', (event) => {
    DebugMessage(`Menu Initialised`);
    FARREL.AdminMenu.Action.SelectedCat = $('.menu-page-action-header-categories').find('.active');
    window.addEventListener('message', function(event){
        let Action = event.data.Action;
        let Data = event.data
        switch(Action) {
            case "Open":
                FARREL.AdminMenu.Open(Data);
                break;
            case "Close":
                if (!FARREL.AdminMenu.Opened) return;
                FARREL.AdminMenu.Close();
                break;
            case "Update":
                if (!FARREL.AdminMenu.Opened) return;
                FARREL.AdminMenu.Update(Data);
                break;
            case "SetItemEnabled":
                FARREL.AdminMenu.EnabledItems[Data.Name] = Data.State;
                Data.State ? $(`#admin-option-${Data.Name}`).addClass('enabled') : $(`#admin-option-${Data.Name}`).removeClass('enabled');
                break;
            case 'Copy':
                FARREL.AdminMenu.Copy(Data.String);
                break;
        }
    });
});

$(document).on({
    keydown: function(e) {
        if (e.key == 'Escape' && FARREL.AdminMenu.Opened) {
            FARREL.AdminMenu.Close();
        }
    },
});