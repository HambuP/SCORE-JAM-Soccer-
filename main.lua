local love = require("love")
local assets = require("code/Assets")
local juice = require("code/juice")
local timer = require("code/timer")

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
local movimiento_duracion_actual = 1.0
local movimiento_activo = false
local posicion_portero = 6
local seleccion_portero = true
local curva_direccion = 0  -- -1 para izquierda, 1 para derecha
local curva_control_x = 0
local curva_control_y = 0

local offset_timing_bar = 0 -- Va entre -1 ; 1, 0 significa en el centro.
local timing_bar_speed_mult = 2 -- Entre más alto el escalar, más rápido duh
local timing_bar_state = 0 -- número entre 0 y 1, 0 acaba de empezar, 1 termina, entre 0 y 1 una posición en la barra
local timing_bar_visible = false -- No voy a explicar esto
local timing_bar_start = 0 -- tiempo exacto en el que empieza

local bar = {}

local mouse_presionado = false

-- Sistema de puntuación
local score = 0
local highest_score = 0
local numeros_img = nil
local numero_width = 50
local numero_height = 50

local score_canvas

local score_actual = {
    rotation = 0,
    scale = 1,
    color = {1,1,1,1}
}

-- Mapa de coordenadas de sprites
local numero_coords = {
    [0] = {x = 60, y = 245},  -- 0
    [1] = {x = 2, y = 5},     -- 1
    [2] = {x = 60, y = 5},    -- 2
    [3] = {x = 0, y = 65},    -- 3
    [4] = {x = 60, y = 65},   -- 4
    [5] = {x = 0, y = 125},   -- 5
    [6] = {x = 60, y = 125},  -- 6
    [7] = {x = 0, y = 185},   -- 7
    [8] = {x = 60, y = 185},  -- 8
    [9] = {x = 0, y = 245}    -- 9
}

Tiros = {
    "recto", "recto","recto","recto","recto",
    "curve", "curve","curve",
    "powershot",
    "knuckelball"
}

-- Sistema de audio
local Sounds = {
    musica = nil,
    gamestart = nil,
    soccerkick = nil,
    point = nil,
    tenpoint = nil,
    gameover = nil
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

    assets.fondo.sprite.imagen = love.graphics.newImage(assets.fondo.sprite.path)
    _G.fondo_img = love.graphics.newImage("assets/fondo.png")
    Imagenes.fondo = fondo_img

    assets.spacestart.sprite.imagen = love.graphics.newImage(assets.spacestart.sprite.path)
    _G.spacestart_img = love.graphics.newImage("assets/spacestart.png")
    Imagenes.spacestart = spacestart_img

    assets.titulo.sprite.imagen = love.graphics.newImage(assets.titulo.sprite.path)
    _G.titulo_img = love.graphics.newImage("assets/titulo.png")
    Imagenes.titulo = titulo_img

    _G.gameover_img = love.graphics.newImage("assets/gameover.png")
    Imagenes.gameover = gameover_img

    bar.front = love.graphics.newImage("assets/barra_front.png")
    bar.back = love.graphics.newImage("assets/barra_back.png")
    bar.timing = love.graphics.newImage("assets/barra_timing.png")
    bar.barrita = love.graphics.newImage("assets/barra_barrita.png")

    -- Cargar sprite de números
    numeros_img = love.graphics.newImage("assets/numeros.png")

    score_canvas = love.graphics.newCanvas(60, 60*5)

    love.graphics.setCanvas(score_canvas)
    love.graphics.clear(0,0,0,0)
    love.graphics.setCanvas()
    -- Cargar sonidos
    Sounds.musica = love.audio.newSource("sound/musica.wav", "stream")
    Sounds.musica:setLooping(true)
    Sounds.gamestart = love.audio.newSource("sound/gamestart.mp3", "static")
    Sounds.soccerkick = love.audio.newSource("sound/soccerkick.mp3", "static")
    Sounds.point = love.audio.newSource("sound/point.mp3", "static")
    Sounds.tenpoint = love.audio.newSource("sound/10point.mp3", "static")
    Sounds.gameover = love.audio.newSource("sound/gameover.mp3", "static")

    -- Iniciar música de fondo
    Sounds.musica:play()
end

local function reset_ronda()
    -- Resetear variables para nueva ronda
    countdown = 1
    activo = true
    seleccion_portero = true
    posicion_portero = 6
    movimiento_progreso = 0
    timing_bar_visible = false
    timing_bar_state = 0
    elemento_aleatorio = 0
    numero = 0
    timing_bar_speed_mult = 3

    -- Resetear posición y escala del balón
    assets.balon.x = 0
    assets.balon.y = 0
    assets.balon.scale = 1

    -- Ocultar gameover
    assets.gameover.visibilidad = false

    -- Resetear estados
    GameStates.menu = false
    GameStates.kick = true
    GameStates.reaction = false
    GameStates.timing = false
    GameStates.result = false
    GameStates.gameover = false
    
end

local function reset_juego()
    -- Reset completo incluyendo score
    score = 0
    reset_ronda()

    -- Volver al menú
    GameStates.menu = true
    GameStates.kick = false
end

local function aumentar_score()
    score = score + 1

    timing_bar_speed_mult = 3 + score/10

    score_actual = {
        rotation = math.random()*2 - 1,
        scale = 1.6
    }
    timer.tween(1, score_actual, {rotation = 0}, "bounce")
    timer.tween(1, score_actual, {scale = 1}, "out-elastic")
    timer.during(1,
        function()
            score_actual.color[1] = (juice.shake.smooth_seesaw(10, 0)/2 + 0.5)
            score_actual.color[2] = (juice.shake.smooth_seesaw(10, 2)/2 + 0.5)
            score_actual.color[3] = (juice.shake.smooth_seesaw(10, 4)/2 + 0.5)
        end,
        function()
            score_actual.color[1] = 1
            score_actual.color[2] = 1
            score_actual.color[3] = 1
        end
    )
end


local function draw_score()
    -- Convertir score a string de dígitos
    local score_str = tostring(score)
    local num_digits = #score_str

    -- Calcular posición central
    local total_width = num_digits * numero_width
    local start_x = (game_width - total_width) / 2
    local start_y = 10  -- 10 píxeles desde arriba

    -- Dibujar cada dígito
    for i = 1, num_digits do
        local digit = tonumber(score_str:sub(i, i))
        local coords = numero_coords[digit]

        -- Crear quad para el dígito
        local quad = love.graphics.newQuad(
            coords.x, coords.y,
            numero_width, numero_height,
            numeros_img:getWidth(), numeros_img:getHeight()
        )

        -- Posición x para este dígito
        local x = start_x + (i - 1) * numero_width

        -- Dibujar dígito

        local drawable = love.graphics.getCanvas()
        local color = {love.graphics.getColor()}
        love.graphics.setCanvas(score_canvas)
        love.graphics.clear(0,0,0,0)
        love.graphics.setColor(score_actual.color[1], score_actual.color[2], score_actual.color[3])
        love.graphics.draw(numeros_img, quad, 0, 0)
        love.graphics.setCanvas(drawable)
        love.graphics.setColor(color)
        --local blend = love.graphics.getBlendMode()
        --love.graphics.setBlendMode("add")
        love.graphics.draw(score_canvas, start_x + juice.shake.smooth_seesaw(0.5)*3 + juice.shake.sin_shake(3), start_y, score_actual.rotation, score_actual.scale)
    end
end

function love.update(dt)
    timer.update(dt)
    if GameStates.menu then

        assets.balon.visibilidad = false
        assets.cancha.visibilidad = true
        assets.portero.visibilidad = false
        assets.sombras.arriba.visibilidad = false
        assets.sombras.abajo_derecha.visibilidad = false
        assets.sombras.abajo_izquierda.visibilidad = false
        assets.sombras.arriba_derecha.visibilidad = false
        assets.sombras.arriba_izquierda.visibilidad = false
        assets.fondo.visibilidad = true
        assets.titulo.visibilidad = true
        assets.spacestart.visibilidad = true

        if love.keyboard.isDown("space") then
            Sounds.gamestart:play()
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
        assets.fondo.visibilidad = false
        assets.titulo.visibilidad = false
        assets.spacestart.visibilidad = false

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

                -- Establecer duración según el tipo de tiro
                if elemento_aleatorio == "powershot" then
                    movimiento_duracion_actual = movimiento_duracion / 2  -- Mitad del tiempo
                else
                    movimiento_duracion_actual = movimiento_duracion  -- Tiempo normal
                end

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
                Sounds.soccerkick:play()
                GameStates.kick = false
                GameStates.reaction = true
            end
        end

    end

    if GameStates.reaction then
        if movimiento_activo then
            mover_balon(dt, elemento_aleatorio, origin_x, origin_y, target_x, target_y, origin_scale, target_scale)
            assets.portero.x = juice.shake.smooth_seesaw(2)*4
            assets.portero.y = juice.shake.smooth_seesaw(8)
        end
    end

    if GameStates.timing then
        assets.portero.x = 0
        assets.portero.y = 0
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
        
        local duracion = 3 / timing_bar_speed_mult
        if posicion_portero == numero then
            if timing_bar_visible == false then
                timing_bar_visible = true
                math.randomseed(os.clock())
                -- Generar timing con límites: entre -0.7 y 0.7 en lugar de -1 a 1
                -- Esto evita que aparezca muy al borde
                local timing = math.random() * 0.7 * 2 - 0.7  -- Rango: -0.7 a 0.7
                local timing = math.random()*1.5 - 0.7
                offset_timing_bar = timing
                timing_bar_start = os.clock()
            else
                timing_bar_state = ( os.clock() - timing_bar_start ) / duracion
                if timing_bar_state > 1 then
                    -- Se acabó el tiempo sin hacer clic
                    Sounds.gameover:play()
                    GameStates.timing = false
                    GameStates.gameover = true
                    timing_bar_visible = false
                    timing_bar_state = 0
                end
                if mouse_presionado then
                    -- Convertir offset_timing_bar (-1 a 1) a posición en la barra (0 a 1)
                    local target_position = (offset_timing_bar + 1) / 2
                    local diff = math.abs(timing_bar_state - target_position)
                    if diff < 0.1 then
                        -- ¡Éxito! Timing perfecto
                        print("¡Buen timing! Diferencia: " .. diff)
                        GameStates.timing = false
                        GameStates.result = true
                        timing_bar_visible = false
                        timing_bar_state = 0
                    else
                        -- Falló el timing
                        print("Mal timing. Diferencia: " .. diff)
                        Sounds.gameover:play()
                        GameStates.timing = false
                        GameStates.gameover = true
                        timing_bar_visible = false
                        timing_bar_state = 0
                    end
                end
            end
        else
            -- El portero atajó el balón
            Sounds.gameover:play()
            GameStates.timing = false
            GameStates.gameover = true
        end
    end
    if GameStates.result then
        -- Incrementar score
        aumentar_score()

        -- Reproducir sonido según score
        if score % 10 == 0 then
            Sounds.tenpoint:play()
        else
            Sounds.point:play()
        end

        -- Resetear para nueva ronda
        reset_ronda()
    end

    if GameStates.gameover then
        -- Actualizar highest score
        if score > highest_score then
            highest_score = score
        end

        -- Mostrar cancha, balón, portero, sombra del portero y fondo oscuro
        assets.balon.visibilidad = true
        assets.portero.visibilidad = true
        assets.cancha.visibilidad = true
        assets.gameover.visibilidad = true
        assets.fondo.visibilidad = true

        -- Mostrar solo la sombra correspondiente a la posición del portero
        assets.sombras.arriba.visibilidad = (posicion_portero == 3)
        assets.sombras.abajo_derecha.visibilidad = (posicion_portero == 5)
        assets.sombras.abajo_izquierda.visibilidad = (posicion_portero == 1)
        assets.sombras.arriba_derecha.visibilidad = (posicion_portero == 4)
        assets.sombras.arriba_izquierda.visibilidad = (posicion_portero == 2)

        -- Ocultar elementos de menú
        assets.titulo.visibilidad = false
        assets.spacestart.visibilidad = false

        -- Detectar reinicio (presionar R o SPACE)
        if love.keyboard.isDown("space") or love.keyboard.isDown("r") then
            reset_juego()
        end
    end

    mouse_presionado = false
end

local function draw_timing_bar(x, y)
    -- Dibujar fondo
    love.graphics.draw(bar.back, x, y)

    -- Dibujar objetivo (timing mark) - offset basado en offset_timing_bar
    local timing_offset_x = (bar.back:getWidth()/2) * offset_timing_bar
    love.graphics.draw(bar.timing, x + timing_offset_x, y)

    -- Dibujar marco frontal
    love.graphics.draw(bar.front, x, y)

    -- Dibujar barrita de progreso - offset basado en timing_bar_state
    local barrita_offset_x = (bar.back:getWidth()) * (timing_bar_state)
    love.graphics.draw(bar.barrita, x + barrita_offset_x, y)
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
        "balon",
        "fondo",
        "gameover",
        "spacestart",
        "titulo"
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

    -- Dibujar timing bar dentro del canvas si está activa
    if GameStates.timing and timing_bar_visible then
        -- Centrar la barra: (360 - ancho_barra) / 2
        -- Bajar un poco la posición Y
        local bar_x = (game_width - bar.back:getWidth()) / 2
        local bar_y = 60  -- Bajada desde 10 a 60
        draw_timing_bar(bar_x, bar_y)
    end

    -- Dibujar score (siempre visible excepto en menú)
    if not GameStates.menu then
        draw_score()
    end

    -- Mostrar highest score en GAMEOVER
    if GameStates.gameover then
        love.graphics.setColor(1, 1, 1, 1)
        local msg_highest = "HIGHEST: " .. tostring(highest_score)
        love.graphics.print(msg_highest, 180, 320, 0, 1.5, 1.5,
            love.graphics.getFont():getWidth(msg_highest) / 2,
            love.graphics.getFont():getHeight() / 2)
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
        
        movimiento_progreso = movimiento_progreso + (dt / movimiento_duracion_actual)

        
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

        movimiento_progreso = movimiento_progreso + (dt / movimiento_duracion_actual)


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

    if tiro == "powershot" then

        movimiento_progreso = movimiento_progreso + (dt / movimiento_duracion_actual)


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

    if tiro== "knuckelball" then

        movimiento_progreso = movimiento_progreso + (dt / movimiento_duracion_actual)


        if movimiento_progreso >= 1 then
            movimiento_progreso = 1
            movimiento_activo = false
            GameStates.reaction = false
            GameStates.timing = true
        end

        -- Movimiento base lineal
        local base_x = xorigin + (xtarget - xorigin) * movimiento_progreso
        local base_y = yorigin + (ytarget - yorigin) * movimiento_progreso

        -- Oscilación errática con múltiples frecuencias (efecto knuckleball)
        -- Usar seno y coseno con diferentes frecuencias para crear movimiento impredecible
        local t = movimiento_progreso
        local frecuencia1 = 12  -- Oscilación rápida
        local frecuencia2 = 7   -- Oscilación media
        local amplitud_x = 25   -- Amplitud horizontal
        local amplitud_y = 15   -- Amplitud vertical

        -- Reducir amplitud al principio y al final para que salga y llegue bien
        local fade = math.sin(t * math.pi)

        -- Combinar múltiples ondas sinusoidales para efecto errático
        local zigzag_x = (math.sin(t * frecuencia1 * math.pi) * 0.6 +
                         math.cos(t * frecuencia2 * math.pi) * 0.4) * amplitud_x * fade

        local zigzag_y = (math.cos(t * frecuencia1 * math.pi) * 0.5 +
                         math.sin(t * frecuencia2 * math.pi) * 0.5) * amplitud_y * fade

        assets.balon.x = base_x + zigzag_x
        assets.balon.y = base_y + zigzag_y
        assets.balon.scale = scaleori + (scaletarget - scaleori) * movimiento_progreso
    end
end

function love.mousepressed( x, y, button, istouch, presses )
    if button == 1 then
        mouse_presionado = true
    end 
end