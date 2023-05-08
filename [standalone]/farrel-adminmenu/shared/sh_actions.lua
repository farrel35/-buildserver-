Config.AdminMenus = {
    {
        ['Id'] = 'player',
        ['Name'] = 'Player',
        ['Items'] = {
            {
                ['Id'] = 'noclip',
                ['Name'] = 'Noclip',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:Noclip',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'changeModel',
                ['Name'] = 'Change Model',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Change:Model',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'model',
                        ['Name'] = 'Model',
                        ['Type'] = 'input',
                        ['Value'] = '',
                    },
                },
            },
            {
                ['Id'] = 'clone',
                ['Name'] = 'Clone',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Change:Clone',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'rmodel',
                ['Name'] = 'Reset Model',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Reset:Model',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'clothing',
                ['Name'] = 'Clothing',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Open:Clothing',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'armor',
                ['Name'] = 'Armor',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Armor',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'food-drink',
                ['Name'] = 'Food & Drink',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Food:Drink',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'godmode',
                ['Name'] = 'Godmode',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Godmode',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'opinventory',
                ['Name'] = 'Open Inventory',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:OpenInv',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'revive',
                ['Name'] = 'Revive',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Revive',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'reviveRadius',
                ['Name'] = 'Revive in Radius',
                ['Groups'] = {'admin'},
                ['Event'] = 'farrel-adminmenu/server/revive-in-distance',
                ['EventType'] = 'Server',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'removeStress',
                ['Name'] = 'Remove Stress',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Remove:Stress',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
        }
    },
    {
        ['Id'] = 'utility',
        ['Name'] = 'Utility',
        ['Items'] = {
            {
                ['Id'] = 'playerblips',
                ['Name'] = 'Player Blips',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:PlayerBlips',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'playernames',
                ['Name'] = 'Player Names',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:PlayerNames',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'deleteVehicle',
                ['Name'] = 'Delete Vehicle',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Delete:Vehicle',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'spawnVehicle',
                ['Name'] = 'Spawn Vehicle',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Spawn:Vehicle',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'model',
                        ['Name'] = 'Model',
                        ['Type'] = 'text',
                        -- ['Choices'] = GetAddonVehicles()
                    },
                },
            },
            {
                ['Id'] = 'fixVehicle',
                ['Name'] = 'Fix Vehicle',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Fix:Vehicle',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'entityFreeAim',
                ['Name'] = 'View Free Aim',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:FreeAim',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'entityVehicle',
                ['Name'] = 'View Vehicle',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:ViewVehicle',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'entityObject',
                ['Name'] = 'View Object',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:ViewObject',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'entityPed',
                ['Name'] = 'View Ped',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:ViewPed',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'teleport',
                ['Name'] = 'Teleport',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Teleport',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'type',
                        ['Name'] = 'Type',
                        ['Type'] = 'input-choice',
                        ['Choices'] = {
                            {
                                Text = 'Goto'
                            },
                            {
                                Text = 'Goback'
                            },
                            {
                                Text = 'Bring'
                            },
                            {
                                Text = 'Bringback'
                            }
                        }
                    },
                },
            },
            {
                ['Id'] = 'teleportCoords',
                ['Name'] = 'Teleport Coords',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Teleport:Coords',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'x-coord',
                        ['Name'] = 'X Coord',
                        ['Type'] = 'input',
                        ['InputType'] = 'number',
                    },
                    {
                        ['Id'] = 'y-coord',
                        ['Name'] = 'Y Coord',
                        ['Type'] = 'input',
                        ['InputType'] = 'number',
                    },
                    {
                        ['Id'] = 'z-coord',
                        ['Name'] = 'Z Coord',
                        ['Type'] = 'input',
                        ['InputType'] = 'number',
                    },
                },
            },
            {
                ['Id'] = 'teleportMarker',
                ['Name'] = 'Teleport Marker',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Teleport:Marker',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'chatSay',
                ['Name'] = 'cSay',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Chat:Say',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'message',
                        ['Name'] = 'Message',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    }
                }
            },
            {
                ['Id'] = 'copyCoords',
                ['Name'] = 'Copy Coords',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Copy:Coords',
                ['Collapse'] = true,
                ['Options'] = {
                    {
            
                        ['Id'] = 'type',
                        ['Name'] = 'Type',
                        ['Type'] = 'input-choice',             
                        ['Choices'] = {
                            {
                                Text = 'vector3(0.0, 0.0, 0.0)'
                            },
                            {
                                Text = 'vector4(0.0, 0.0, 0.0, 0.0)'
                            },
                            {
                                Text = '0.0, 0.0, 0.0'
                            },
                            {
                                Text = '0.0, 0.0, 0.0, 0.0'
                            },
                            {
                                Text = 'X = 0.0, Y = 0.0, Z = 0.0'
                            },
                            {
                                Text = 'x = 0.0, y = 0.0, z = 0.0'
                            },
                            {
                                Text = 'X = 0.0, Y = 0.0, Z = 0.0, H = 0.0'
                            },
                            {
                                Text = 'x = 0.0, y = 0.0, z = 0.0, h = 0.0'
                            },
                            {
                                Text = '["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0'
                            },
                            {
                                Text = '["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0'
                            },
                            {
                                Text = '["X"] = 0.0, ["Y"] = 0.0, ["Z"] = 0.0, ["H"] = 0.0'
                            },
                            {
                                Text = '["x"] = 0.0, ["y"] = 0.0, ["z"] = 0.0, ["h"] = 0.0'
                            }
                        }
                    },
                },
            },
            
        }
    },

    {
        ['Id'] = 'fun',
        ['Name'] = 'Fun',
        ['Items'] = {
            {
                ['Id'] = 'flingPlayer',
                ['Name'] = 'Fling Player',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Fling:Player',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'drunkPlayer',
                ['Name'] = 'Make Player Drunk',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Drunk',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'animalattackPlayer',
                ['Name'] = 'Animal Attack',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Animal:Attack',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'setfirePlayer',
                ['Name'] = 'Set On Fire',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Set:Fire',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                },
            },
            {
                ['Id'] = 'soundPlayer',
                ['Name'] = 'Play Sound',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Sound:Player',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'sound',
                        ['Name'] = 'Sound',
                        ['Type'] = 'input-choice',
                        ['Choices'] = {
                            {
                                Text = 'Fart'
                            },
                            {
                                Text = 'Wet Fart'
                            },
                        },
                    },
                },
            },
            {
                ['Id'] = 'drone',
                ['Name'] = 'Play Drone',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:Drone',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
            {
                ['Id'] = 'powerMode',
                ['Name'] = 'Power Mode',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:PowerMode',
                ['EventType'] = 'Client',
                ['Collapse'] = false,
            },
        }
    },
    {
        ['Id'] = 'user',
        ['Name'] = 'User',
        ['Items'] = {
            {
                ['Id'] = 'setjob',
                ['Name'] = 'Request Job',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Request:Job',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'job',
                        ['Name'] = 'Job',
                        ['Type'] = 'text-choice',
                        ['Choices'] = GetJobs()
                    },
                },
            },
            {
                ['Id'] = 'giveItem',
                ['Name'] = 'Give Item',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:GiveItem',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'item',
                        ['Name'] = 'Item',
                        ['Type'] = 'input-choice',
                        ['Choices'] = GetInventoryItems()
                    },
                    {
                        ['Id'] = 'amount',
                        ['Name'] = 'Amount',
                        ['Type'] = 'input',
                        ['InputType'] = 'number',
                    },
                },
            },
            {
                ['Id'] = 'banPlayerOffline',
                ['Name'] = 'Ban Player Offline',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:BanOffline',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'steamhex',
                        ['Name'] = 'Steamhex',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                    {
                        ['Id'] = 'expire',
                        ['Name'] = 'Expire',
                        ['Type'] = 'input-choice',
                        ['Choices'] = {
                            {
                                Text = '1 Hour'
                            },
                            {
                                Text = '6 Hours'
                            },
                            {
                                Text = '12 Hours'
                            },
                            {
                                Text = '1 Day'
                            },
                            {
                                Text = '3 Days'
                            },
                            {
                                Text = '1 Week'
                            },
                            {
                                Text = 'Permanent'
                            }
                        }
                    },
                    {
                        ['Id'] = 'reason',
                        ['Name'] = 'Reason',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                },
            },
            {
                ['Id'] = 'banPlayer',
                ['Name'] = 'Ban Player',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Ban',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'expire',
                        ['Name'] = 'Expire',
                        ['Type'] = 'input-choice',
                        ['Choices'] = {
                            {
                                Text = '1 Hour'
                            },
                            {
                                Text = '6 Hours'
                            },
                            {
                                Text = '12 Hours'
                            },
                            {
                                Text = '1 Day'
                            },
                            {
                                Text = '3 Days'
                            },
                            {
                                Text = '1 Week'
                            },
                            {
                                Text = 'Permanent'
                            }
                        }
                    },
                    {
                        ['Id'] = 'reason',
                        ['Name'] = 'Reason',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                },
            },
            {
                ['Id'] = 'unbanPlayer',
                ['Name'] = 'Unban Player',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Unban',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['Choices'] = {}
                    },
                },
            },
            {
                ['Id'] = 'kickPlayer',
                ['Name'] = 'Kick Player',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Kick',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'reason',
                        ['Name'] = 'Reason',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                },
            },
            {
                ['Id'] = 'spectate',
                ['Name'] = 'Spectate Player',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:Toggle:Spectate',
                ['EventType'] = 'Client',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                }
            },
            {
                ['Id'] = 'givevehicle',
                ['Name'] = 'Give Vehicle',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:GiveVehicle',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'player',
                        ['Name'] = 'Player',
                        ['Type'] = 'input-choice',
                        ['PlayerList'] = true,
                    },
                    {
                        ['Id'] = 'model',
                        ['Name'] = 'Model',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                    {
                        ['Id'] = 'plate',
                        ['Name'] = 'Plate(kosong = random)',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                }
            },
            {
                ['Id'] = 'givevehicleoff',
                ['Name'] = 'Give Vehicle Offline',
                ['Groups'] = {'admin'},
                ['Event'] = 'Admin:GiveVehicleOffline',
                ['Collapse'] = true,
                ['Options'] = {
                    {
                        ['Id'] = 'steamhex',
                        ['Name'] = 'Steam Hex',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                    {
                        ['Id'] = 'model',
                        ['Name'] = 'Model',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                    {
                        ['Id'] = 'plate',
                        ['Name'] = 'Plate(kosong = random)',
                        ['Type'] = 'input',
                        ['InputType'] = 'text',
                    },
                }
            },
        }
    },
}