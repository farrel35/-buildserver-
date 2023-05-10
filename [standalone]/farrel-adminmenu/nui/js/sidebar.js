// [ SIDEBAR ] \\

FARREL.AdminMenu.Sidebar.Selected = "Actions";

FARREL.AdminMenu.LoadCategory = function(Category) {
    $('.menu-pages').find(`[data-Page="${FARREL.AdminMenu.Sidebar.Selected}"`).fadeIn(150);
    if (Category == 'Actions') {
        FARREL.AdminMenu.LoadItems();
    } else if (Category == 'PlayerList') {
        FARREL.AdminMenu.LoadPlayerList();
    } else if (Category == 'PlayerLogs') {
        FARREL.AdminMenu.ResetPage('All');
        FARREL.AdminMenu.LoadPlayerLogs();
    }
}

FARREL.AdminMenu.SidebarAction = function(Action, Element) {
    if (Action == 'DevMode') {
        if ($(Element).hasClass('enabled')) {
            $(Element).removeClass('enabled')
            $.post(`https://${GetParentResourceName()}/Admin/DevMode`, JSON.stringify({
                Toggle: false,
            }));
        } else {
            $(Element).addClass('enabled')
            $.post(`https://${GetParentResourceName()}/Admin/DevMode`, JSON.stringify({
                Toggle: true,
            }));
        }
    } else if (Action == 'ToggleMenu') {
        FARREL.AdminMenu.Close();
    }
}

// [ CLICKS ] \\
let Timeout = false;
$(document).on('click', ".menu-sidebar-action", function (e) {
    e.preventDefault();

    let NewSidebarCat = $(this);
    let OldSidebarCat = $(this).attr('data-Action');
    if (FARREL.AdminMenu.Sidebar.Selected != OldSidebarCat && !Timeout) {
        Timeout = true;
        setTimeout(() => {
            Timeout = false;
        }, 300);
        if (NewSidebarCat.hasClass('lower')) {
            FARREL.AdminMenu.SidebarAction(OldSidebarCat, NewSidebarCat)
        } else {
            let PreviousSidebarCat = $(`[data-Action="${FARREL.AdminMenu.Sidebar.Selected}"]`);

            FARREL.AdminMenu.LoadCategory(OldSidebarCat);
            DebugMessage(`Changing Sidebar Category: ${FARREL.AdminMenu.Sidebar.Selected} -> ${OldSidebarCat}`)
            
            $(PreviousSidebarCat).removeClass('selected');
            $(NewSidebarCat).addClass('selected');
    
            $(`[data-Page="${FARREL.AdminMenu.Sidebar.Selected}"`).fadeOut(150);
            $(`[data-Page="${OldSidebarCat}"`).fadeIn(150);
    
            setTimeout(function(){ FARREL.AdminMenu.Sidebar.Selected = OldSidebarCat; }, 200);
        }
    }
});