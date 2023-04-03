// [ PLAYER LIST ] \\

MC.AdminMenu.LoadPlayerList = function() {
    DebugMessage('Loading PlayerList.');
    if (MC.AdminMenu.Players != "" && MC.AdminMenu.Players != null) {
        MC.AdminMenu.BuildPlayerList();
    } else {
        DebugMessage('No players found.');
    }
}

MC.AdminMenu.BuildPlayerList = function() {
    DebugMessage('Building PlayerList.');
    $('.admin-menu-players').html('');
    for (let i = 0; i < MC.AdminMenu.Players.length; i++) {
        let Player = MC.AdminMenu.Players[i];
        let PlayerItem = `<div class="admin-menu-player" id="admin-player-${Player['ServerId']}">
                            <div class="admin-menu-player-id">(${Player['ServerId']})</div>
                            <div class="admin-menu-player-name">${Player['Name']}</div>
                            <div class="admin-menu-player-steam">[${Player['Steam']}]</div>
                        </div>`;

       
        $('.admin-menu-players').append(PlayerItem);
        $(`#admin-player-${Player['ServerId']}`).data('PlayerData', Player);       
    } 
}

// [ SEARCH ] \\

$(document).on('input', '#list-serverid', function(e){
    let SearchText = $(this).val().toLowerCase();

    $('.admin-menu-player').each(function(Elem, Obj){
        if ($(this).find('.admin-menu-player-id').html().toLowerCase().includes(SearchText)) {
            $(this).fadeIn(150);
        } else {
            $(this).fadeOut(150);
        };
    });
});

$(document).on('input', '#list-steamsearch', function(e){
    let SearchText = $(this).val().toLowerCase();

    $('.admin-menu-player').each(function(Elem, Obj){
        if ($(this).find('.admin-menu-player-steam').html().toLowerCase().includes(SearchText)) {
            $(this).fadeIn(150);
        } else {
            $(this).fadeOut(150);
        };
    });
});

// [ CLICKS ] \\
