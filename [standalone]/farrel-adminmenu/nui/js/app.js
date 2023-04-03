MC = {}
MC.AdminMenu = {}

MC.AdminMenu.Action = {}
MC.AdminMenu.Category = {}
MC.AdminMenu.Sidebar = {}
MC.AdminMenu.PlayerList = {}
MC.AdminMenu.SizeChange = {}

MC.AdminMenu.DebugEnabled = null;
MC.AdminMenu.Opened = false;
MC.AdminMenu.IsGeneratingDropdown = false;

MC.AdminMenu.FavoritedItems = {};
MC.AdminMenu.EnabledItems = {};

MC.AdminMenu.Players = null;
MC.AdminMenu.Items = null;
MC.AdminMenu.CurrentTarget = null;
MC.AdminMenu.Size = "Small";

// Editable

MC.AdminMenu.SizeChange.LeftArrow = '<i class="fas fa-chevron-left"></i>'; // Arrow when menu can be changed to large
MC.AdminMenu.SizeChange.RightArrow = '<i class="fas fa-chevron-right"></i>'; // Arrow when menu can be changed to small

// Code

MC.AdminMenu.Update = function(Data) {
    DebugMessage(`Menu Updating`);
    MC.AdminMenu.FavoritedItems = Data.Favorited;
    MC.AdminMenu.Players = Data.AllPlayers;
    MC.AdminMenu.Items = Data.AdminItems;
    if (MC.AdminMenu.Sidebar.Selected == 'Actions') {
        MC.AdminMenu.LoadItems();
    } else if (MC.AdminMenu.Sidebar.Selected == 'PlayerList') {
        MC.AdminMenu.LoadPlayerList();
    }
}
 
MC.AdminMenu.Open = function(Data) {
    MC.AdminMenu.DebugEnabled = Data.Debug;
    MC.AdminMenu.FavoritedItems = Data.Favorited;
    DebugMessage(`Menu Opening`);
    $('.menu-main-container').css('pointer-events', 'auto');
    $('.menu-main-container').fadeIn(450, function() {
        if (MC.AdminMenu.Items == null && MC.AdminMenu.Players == null) {
            MC.AdminMenu.Players = Data.AllPlayers
            MC.AdminMenu.Items = Data.AdminItems
            $('.menu-pages').find(`[data-Page="${MC.AdminMenu.Sidebar.Selected}"`).fadeIn(150);
            MC.AdminMenu.LoadCategory(MC.AdminMenu.Sidebar.Selected);
        };
        MC.AdminMenu.Players = Data.AllPlayers
        MC.AdminMenu.Opened = true;
    });
    if (MC.AdminMenu.Sidebar.Selected == 'Actions') {
        MC.AdminMenu.LoadItems();
    } else if (MC.AdminMenu.Sidebar.Selected == 'PlayerList') {
        MC.AdminMenu.LoadPlayerList();
    }
}


MC.AdminMenu.Close = function() {
    DebugMessage(`Menu Closing`);
    MC.AdminMenu.ClearDropdown();
    $.post(`https://${GetParentResourceName()}/Admin/Close`);
    $('.menu-main-container').css('pointer-events', 'none');
    $('.menu-main-container').fadeOut(150, function() {
        MC.AdminMenu.Opened = false; 
    });
}

MC.AdminMenu.ChangeSize = function(ForceSize) {
    let Styles = getComputedStyle(document.body);
    if (ForceSize != null && ForceSize == 'Large' || MC.AdminMenu.Size == 'Small' && ForceSize == null) {
        $('.menu-size-change').html(MC.AdminMenu.SizeChange.RightArrow);
        MC.AdminMenu.Size = 'Large';
        $('.menu-main-container').css({
            width: Styles.getPropertyValue('--menu-large-width'),
            right: 19+"%",
        });
    } else if (ForceSize != null && ForceSize == 'Small' || MC.AdminMenu.Size == 'Large' && ForceSize == null) {
        $('.menu-size-change').html(MC.AdminMenu.SizeChange.LeftArrow);
        MC.AdminMenu.Size = 'Small';
        $('.menu-main-container').css({
            width: Styles.getPropertyValue('--menu-small-width'),
            right: 3+"%",
        });
    }
}

MC.AdminMenu.Copy = function(Text) {
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
    MC.AdminMenu.ChangeSize()
});

$(document).on('click', '.menu-current-target', function(e){
    $(this).parent().find('.ui-styles-input').each(function(Elem, Obj){
        if ($(this).find('input').data("PlayerId")) {
            if (MC.AdminMenu.CurrentTarget != null) {
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
    MC.AdminMenu.CurrentTarget = null;
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
    if (MC.AdminMenu.DebugEnabled) {
        console.log(`[DEBUG]: ${Message}`);
    }
}

// [ LISTENER ] \\

document.addEventListener('DOMContentLoaded', (event) => {
    DebugMessage(`Menu Initialised`);
    MC.AdminMenu.Action.SelectedCat = $('.menu-page-action-header-categories').find('.active');
    window.addEventListener('message', function(event){
        let Action = event.data.Action;
        let Data = event.data
        switch(Action) {
            case "Open":
                MC.AdminMenu.Open(Data);
                break;
            case "Close":
                if (!MC.AdminMenu.Opened) return;
                MC.AdminMenu.Close();
                break;
            case "Update":
                if (!MC.AdminMenu.Opened) return;
                MC.AdminMenu.Update(Data);
                break;
            case "SetItemEnabled":
                MC.AdminMenu.EnabledItems[Data.Name] = Data.State;
                Data.State ? $(`#admin-option-${Data.Name}`).addClass('enabled') : $(`#admin-option-${Data.Name}`).removeClass('enabled');
                break;
            case 'Copy':
                MC.AdminMenu.Copy(Data.String);
                break;
        }
    });
});

$(document).on({
    keydown: function(e) {
        if (e.key == 'Escape' && MC.AdminMenu.Opened) {
            MC.AdminMenu.Close();
        }
    },
});