--[[
Que es lo que quiero hacer?
Un modulo fácilmente integrable a cualquier proyecto, que me permita obtener jugoooo
Que es el jugo:
el juice es aquello que esta en un juego que es puramente decorativo y interacciones que añaden al juego

To do:
Pantalla:
ScreenShake
Flashes

Una funcion que acepte un color, una duracion, y un easing, que haga que envie un shader etc no se si valga la pena 

Otras cosas que se me ocurran
Una funcion que permita pasar un frag shader y sus argumentos en forma de lista y una cantidad de frames
por los que se va a ejecutar -- Mejor aún si es una instancia que permita lo mismo pero no unicamente a la pantalla

Objetos:
Shake
Easing
Lerps

Particulas:
Abstracción parcial de las particulas nativas de love2d

]]

local juice = {}

local shake = {}

function shake.sin_shake(frec, phi)
    phi = phi or 0
    local t = (os.clock() * frec * math.pi) + phi
    return math.sin(t)
end

function shake.square_shake(frec, phi)
    phi = phi or 0
    local t = os.clock() * frec + phi
    local period = 1/frec
    return (1 and t%period < (period/2) or -1)
end

function shake.saw_shake(frec, phi)
    phi = phi or 0
    local t = os.clock() * frec + phi
    return ((t*frec*0.5)%1)*2 - 1
end

function shake.smooth_seesaw(frec, phi)
    phi = phi or 0
    local t = (os.clock() * frec * math.pi) + phi
    return math.sin(math.sin(math.sin(t)*1.6)*1.6)
end

juice.shake = shake

return juice
