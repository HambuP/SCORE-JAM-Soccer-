local Assets = {}

Assets.balon = {
    visibilidad =  true,
    x = 0,
    y = 0,
    sprite =  { path = "assets/balon.png", width = 360, height = 420 },
    scale = 1,

    scale_min = 0.5,
    scale_max = 1,

    trayectoria = {},
    velocidad = 500,

    invertible = false,

    cord = {
        {x=-80,y=-150},{x=-80,y=-220},{x=0,y=-220},{x=80,y=-220},{x=80,y=-150}
    }
}

Assets.cancha = {
    visibilidad = true,
    x=0,
    y=0,
    sprite = { path = "assets/Cancha.png", width = 360, height = 420},

    invertible = false
}

Assets.portero = {
    visibilidad = true,
    x=0,
    y=0,
    sprite = { path = "assets/Jugador.png", width = 360, height = 420},
    scale = 1,

    invertible = false
}

Assets.sombras = {
    abajo_derecha = {
        visibilidad = true,
        x=0,
        y=0,
        sprite = { path = "assets/izquierda_abajo.png", width = 360, height = 420},
        scale = 1,
        invertible = true
    },

    abajo_izquierda = {
        visibilidad = true,
        x=0,
        y=0,
        sprite = { path = "assets/izquierda_abajo.png", width = 360, height = 420},
        scale = 1,
        invertible = false
    },

    arriba_derecha = {
        visibilidad = true,
        x=0,
        y=0,
        sprite = { path = "assets/derecha_arriba.png", width = 360, height = 420},
        scale = 1,
        invertible = false
    },

    arriba_izquierda = {
        visibilidad = true,
        x=0,
        y=0,
        sprite = { path = "assets/derecha_arriba.png", width = 360, height = 420},
        scale = 1,
        invertible = true
    },

    arriba = {
        visibilidad = true,
        x=0,
        y=0,
        sprite = { path = "assets/arriba.png", width = 360, height = 420},
        scale = 1,
        invertible = false
    }
}

Assets.titulo = {
    visibilidad = true,
    x=0,
    y=0,
    sprite = { path = "assets/titulo.png", width = 360, height = 420},
    scale = 1,

    invertible = false
}

Assets.spacestart = {
    visibilidad = true,
    x=0,
    y=0,
    sprite = { path = "assets/spacestart.png", width = 360, height = 420},
    scale = 1,

    invertible = false
}

Assets.fondo = {
    visibilidad = true,
    x= 0,
    y=0,
    sprite = { path = "assets/fondo.png", width = 360, height = 420},
    scale = 1,

    invertible = false
}

Assets.gameover = {
    visibilidad = false,
    x= 0,
    y=0,
    sprite = { path = "assets/gameover.png", width = 360, height = 420},
    scale = 1,

    invertible = false
}

return Assets