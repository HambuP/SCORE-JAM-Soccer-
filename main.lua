
local love = require("love")
local assets = require("code/Assets")

local game_width = 360
local game_height = 420

local canvas
local scale = 1
local offset_x = 0
local offset_y = 0

GameStates = {
    menu = true,
    kick = false,
    reaction = false,
    timing = false,
    result = false,
    gameover = false,
}

Imagenes = {}

local countdown = 1
local activo = true
local numero = 0
local elemento_aleatorio = 0
local target_x = 0
local target_y = 0
local target_scale = 1
local origin_x = 0
local origin_y = 0
local origin_scale = 1
local movimiento_progreso = 0
local movimiento_duracion = 1.0
local movimiento_activo = false
local posicion_portero = 6
local seleccion_portero = true
local curva_direccion = 0  -- -1 para izquierda, 1 para derecha
local curva_control_x = 0
local curva_control_y = 0


Tiros = {
    "recto", "curve"
}

function love.load()

    canvas = love.graphics.newCanvas(game_width, game_height)
    canvas:setFilter("nearest", "nearest")
    
    assets.cancha.sprite.imagen = love.graphics.newImage(assets.cancha.sprite.path)
    _G.cancha_img = love.graphics.newImage("assets/Cancha.png")
    Imagenes.cancha = cancha_img
    
    assets.sombras.arriba_izquierda.sprite.imagen = love.graphics.newImage(assets.sombras.arriba_izquierda.sprite.path)
    _G.arri_izq_img = love.graphics.newImage("assets/derecha_arriba.png")
    Imagenes.arriba_izquierda = arri_izq_img
    
    assets.sombras.arriba_derecha.sprite.imagen = love.graphics.newImage(assets.sombras.arriba_derecha.sprite.path)
    _G.arri_der_img = love.graphics.newImage("assets/derecha_arriba.png")
    Imagenes.arriba_derecha = arri_der_img
    
    assets.sombras.abajo_izquierda.sprite.imagen = love.graphics.newImage(assets.sombras.abajo_izquierda.sprite.path)
    _G.abaj_izq_img = love.graphics.newImage("assets/izquierda_abajo.png")
    Imagenes.abajo_izquierda = abaj_izq_img
    
    assets.sombras.abajo_derecha.sprite.imagen = love.graphics.newImage(assets.sombras.abajo_derecha.sprite.path)
    _G.abaj_der_img = love.graphics.newImage("assets/izquierda_abajo.png")
    Imagenes.abajo_derecha = abaj_der_img
    
    assets.sombras.arriba.sprite.imagen = love.graphics.newImage(assets.sombras.arriba.sprite.path)
    _G.arriba_img = love.graphics.newImage("assets/arriba.png")
    Imagenes.arriba = arriba_img

    assets.portero.sprite.imagen = love.graphics.newImage(assets.portero.sprite.path)
    _G.portero_img = love.graphics.newImage("assets/Jugador.png")
    Imagenes.portero = portero_img

    assets.balon.sprite.imagen = love.graphics.newImage(assets.balon.sprite.path)
    _G.balon_img = love.graphics.newImage("assets/balon.png")
    Imagenes.balon = balon_img
end

function love.update(dt)

    if GameStates.menu then

        assets.balon.visibilidad = false
        assets.cancha.visibilidad = false
        assets.portero.visibilidad = false
        assets.sombras.arriba.visibilidad = false
        assets.sombras.abajo_derecha.visibilidad = false
        assets.sombras.abajo_izquierda.visibilidad = false
        assets.sombras.arriba_derecha.visibilidad = false
        assets.sombras.arriba_izquierda.visibilidad = false

        if love.keyboard.isDown("space") then
            GameStates.menu = false
            GameStates.kick = true
        end
    end

    if GameStates.kick then
        assets.balon.visibilidad = true
        assets.cancha.visibilidad = true
        assets.portero.visibilidad = true
        assets.sombras.arriba.visibilidad = false
        assets.sombras.abajo_derecha.visibilidad = false
        assets.sombras.abajo_izquierda.visibilidad = false
        assets.sombras.arriba_derecha.visibilidad = false
        assets.sombras.arriba_izquierda.visibilidad = false

        if activo then
            countdown = countdown - dt
            if countdown <= 0 then
                activo = false
                numero = love.math.random(1, 5)
                elemento_aleatorio = Tiros[love.math.random(#Tiros)]
                origin_x = assets.balon.x
                origin_y = assets.balon.y
                origin_scale = assets.balon.scale
                target_x, target_y = assets.balon.cord[numero].x, assets.balon.cord[numero].y
                target_scale = assets.balon.scale_min

                -- Calcular dirección de la curva según la posición
                if elemento_aleatorio == "curve" then
                    if numero == 3 then
                        -- Centro: aleatorio izquierda o derecha
                        curva_direccion = love.math.random(0, 1) == 0 and -1 or 1
                    elseif numero == 1 or numero == 2 then
                        -- Izquierda: curva hacia la izquierda
                        curva_direccion = -1
                    else
                        -- Derecha: curva hacia la derecha
                        curva_direccion = 1
                    end

                    -- Calcular punto de control para la curva
                    local mid_x = (origin_x + target_x) / 2
                    local mid_y = (origin_y + target_y) / 2
                    curva_control_x = mid_x + (100 * curva_direccion)
                    curva_control_y = mid_y
                end

                movimiento_progreso = 0
                movimiento_activo = true
                GameStates.kick = false
                GameStates.reaction = true
            end
        end

    end

    if GameStates.reaction then
        if movimiento_activo then
            mover_balon(dt, elemento_aleatorio, origin_x, origin_y, target_x, target_y, origin_scale, target_scale)
        end
    end

    if GameStates.timing then
        if posicion_portero == 1 then
            assets.sombras.abajo_izquierda.visibilidad = true
        end
        if posicion_portero == 2 then
            assets.sombras.arriba_izquierda.visibilidad = true
        end
        if posicion_portero == 3 then
            assets.sombras.arriba.visibilidad = true
        end
        if posicion_portero == 4 then
            assets.sombras.arriba_derecha.visibilidad = true
        end
        if posicion_portero == 5 then
            assets.sombras.abajo_derecha.visibilidad = true
        end
 

    end

end

function love.draw()
    love.graphics.setCanvas(canvas)

    local orden_dibujo = {
        "cancha",
        "arriba_izquierda",
        "arriba_derecha",
        "abajo_izquierda",
        "abajo_derecha",
        "arriba",
        "portero",
        "balon"
    }

    for _, valor in ipairs(orden_dibujo) do
        local img = Imagenes[valor]
        local asset = assets[valor] or assets.sombras[valor]

        if img and asset and asset.visibilidad then
            local scale_value = asset.scale or 1

            if asset.invertible then
                local width = asset.sprite.width
                local origin_x = width / 2
                local pos_x = asset.x + origin_x
                love.graphics.draw(img, pos_x, asset.y, 0, -scale_value, scale_value, origin_x, 0)
            else
                
                if scale_value ~= 1 then
                    local width = asset.sprite.width
                    local height = asset.sprite.height
                    local origin_x = width / 2
                    local origin_y = height / 2

                    
                    if valor == "balon" then
                        origin_y = 350  
                    end

                    local pos_x = asset.x + origin_x
                    local pos_y = asset.y + origin_y
                    love.graphics.draw(img, pos_x, pos_y, 0, scale_value, scale_value, origin_x, origin_y)
                else
                    love.graphics.draw(img, asset.x, asset.y)
                end
            end
        end
    end

    love.graphics.setCanvas()
    love.graphics.draw(
        canvas,
        offset_x,
        offset_y,
        0,
        scale,
        scale
    )
end

function love.resize(w,h)
    calcular_escala()
end

function _G.calcular_escala()
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()

    local scale_x = window_width / game_width
    local scale_y = window_height / game_height

    scale = math.min(scale_x, scale_y)

    offset_x = (window_width - (game_width * scale)) / 2
    offset_y = (window_height - (game_height * scale)) / 2
end

function _G.mover_balon(dt, tiro, xorigin, yorigin, xtarget, ytarget, scaleori, scaletarget)
    if love.keyboard.isDown("a") and not love.keyboard.isDown("w") and
       love.mouse.isDown(1) and seleccion_portero then
        posicion_portero = 1
        seleccion_portero = false
    end

    if love.keyboard.isDown("w") and 
       love.keyboard.isDown("a") and 
       love.mouse.isDown(1) and seleccion_portero then
        posicion_portero = 2
        seleccion_portero = false
    end

    if love.keyboard.isDown("w") and not love.keyboard.isDown("a") and not love.keyboard.isDown("d") and 
       love.mouse.isDown(1) and seleccion_portero then
        posicion_portero = 3
        seleccion_portero = false
    end

    if love.keyboard.isDown("w") and 
       love.keyboard.isDown("d") and 
       love.mouse.isDown(1) and seleccion_portero then
        posicion_portero = 4
        seleccion_portero = false
    end

    if love.keyboard.isDown("d") and not love.keyboard.isDown("w")and 
       love.mouse.isDown(1)  and seleccion_portero then
        posicion_portero = 5
        seleccion_portero = false
    end

    if tiro == "recto" then
        
        movimiento_progreso = movimiento_progreso + (dt / movimiento_duracion)

        
        if movimiento_progreso >= 1 then
            movimiento_progreso = 1
            movimiento_activo = false
            GameStates.reaction = false
            GameStates.timing = true
        end

        
        assets.balon.x = xorigin + (xtarget - xorigin) * movimiento_progreso
        assets.balon.y = yorigin + (ytarget - yorigin) * movimiento_progreso
        assets.balon.scale = scaleori + (scaletarget - scaleori) * movimiento_progreso
    end

    if tiro == "curve" then

        movimiento_progreso = movimiento_progreso + (dt / movimiento_duracion)


        if movimiento_progreso >= 1 then
            movimiento_progreso = 1
            movimiento_activo = false
            GameStates.reaction = false
            GameStates.timing = true
        end

        -- Curva cuadrática Bézier: P = (1-t)²*P0 + 2(1-t)*t*P1 + t²*P2
        -- P0 = origen, P1 = punto de control, P2 = destino
        local t = movimiento_progreso
        local t_inv = 1 - t

        assets.balon.x = t_inv * t_inv * xorigin +
                         2 * t_inv * t * curva_control_x +
                         t * t * xtarget

        assets.balon.y = t_inv * t_inv * yorigin +
                         2 * t_inv * t * curva_control_y +
                         t * t * ytarget

        assets.balon.scale = scaleori + (scaletarget - scaleori) * movimiento_progreso
    end
end