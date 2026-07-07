"use strict";

/*
========================================================

 AMIGA GRAPHIC STUDIO

 PNG -> RGB4 -> Bitplanes -> Copper

 Partie 1 : Initialisation et chargement image

========================================================
*/



// ===========================
// VARIABLES GLOBALES
// ===========================


let sourceImage = null;

let imageName = "image";

let imageWidth = 0;
let imageHeight = 0;


let pixels = [];

let amigaPixels = [];

let amigaPalette = [];

let bitplanes = [];

let copperText = "";

let rawData = new Uint8Array();

let showGrid = false;



// Configuration par défaut Amiga 500

let config = {

    depth:5,

    colors:32,

    interleaved:false,

    dithering:"none",

    copper:true,

    copperFormat:"asm",

    rgbMode:"rgb4"

};




// ===========================
// ELEMENTS DOM
// ===========================


const pngFile =
document.getElementById("pngFile");


const originalCanvas =
document.getElementById("originalCanvas");


const amigaCanvas =
document.getElementById("amigaCanvas");


const originalCtx =
originalCanvas.getContext("2d");


const amigaCtx =
amigaCanvas.getContext("2d");



const statusText =
document.getElementById("statusText");



const imgWidth =
document.getElementById("imgWidth");


const imgHeight =
document.getElementById("imgHeight");


const colorCount =
document.getElementById("colorCount");




const depthSelect =
document.getElementById("depthSelect");


const colorSelect =
document.getElementById("colorSelect");



const copperPreview =
document.getElementById("copperPreview");



const logConsole =
document.getElementById("logConsole");





// ===========================
// UTILITAIRES
// ===========================



function log(message)
{

    if(logConsole)
    {
        logConsole.value +=
        "\n" + message;

        logConsole.scrollTop =
        logConsole.scrollHeight;
    }

}





function setStatus(message)
{

    if(statusText)
        statusText.textContent = message;

}







// ===========================
// CHARGEMENT PNG
// ===========================



pngFile.addEventListener(
"change",
loadPNG
);



function loadPNG(event)
{


    const file =
    event.target.files[0];


    if(!file)
        return;



    imageName =
    file.name.replace(
        ".png",
        ""
    );



    setStatus(
        "Chargement..."
    );


    log(
        "Ouverture : "
        + file.name
    );



    const reader =
    new FileReader();



    reader.onload =
    function(e)
    {


        const img =
        new Image();



        img.onload =
        function()
        {

            sourceImage = img;

            imageWidth =
            img.width;


            imageHeight =
            img.height;



            prepareOriginalCanvas();


            readPixels();


            updateInfo();



            setStatus(
                "Image chargée"
            );


            log(
                "Image "
                + imageWidth
                +"x"
                +imageHeight
            );



            convertAmiga();


        };


        img.src =
        e.target.result;

    };



    reader.readAsDataURL(file);

}





// ===========================
// CANVAS ORIGINAL
// ===========================



function prepareOriginalCanvas()
{


    originalCanvas.width =
    imageWidth;


    originalCanvas.height =
    imageHeight;



    originalCtx.clearRect(
        0,
        0,
        imageWidth,
        imageHeight
    );



    originalCtx.drawImage(
        sourceImage,
        0,
        0
    );

}






// ===========================
// LECTURE PIXELS RGBA
// ===========================



function readPixels()
{


    pixels = [];



    const data =
    originalCtx.getImageData(
        0,
        0,
        imageWidth,
        imageHeight
    ).data;




    for(
        let i=0;
        i<data.length;
        i+=4
    )
    {


        pixels.push({

            r:data[i],

            g:data[i+1],

            b:data[i+2],

            a:data[i+3]

        });


    }


}






// ===========================
// RGB888 -> RGB4 AMIGA
// ===========================



function rgb888ToRgb4(r,g,b)
{


    let rr =
    Math.round(r/17);


    let gg =
    Math.round(g/17);


    let bb =
    Math.round(b/17);



    return {

        r:rr,

        g:gg,

        b:bb

    };


}






function rgb4ToHex(c)
{

    return (

        c.r.toString(16)+

        c.g.toString(16)+

        c.b.toString(16)

    ).toUpperCase();


}






function rgb4ToRgb888(c)
{

    return {

        r:c.r*17,

        g:c.g*17,

        b:c.b*17

    };

}





// ===========================
// INFO IMAGE
// ===========================



function updateInfo()
{


    imgWidth.textContent =
    imageWidth;


    imgHeight.textContent =
    imageHeight;


    colorCount.textContent =
    "calcul...";


}

/*
========================================================

 Partie 2 : Palette Amiga RGB4 et conversion couleurs

========================================================
*/



// ===========================
// DISTANCE COULEUR
// ===========================


function colorDistance(a,b)
{


    let dr =
    a.r-b.r;


    let dg =
    a.g-b.g;


    let db =
    a.b-b.b;



    return (

        dr*dr +
        dg*dg +
        db*db

    );


}







// ===========================
// GENERATION PALETTE
// ===========================



function generatePalette()
{


    log(
        "Création palette RGB4..."
    );


    let colors = [];



    /*
       Conversion simple :
       on collecte les couleurs
       existantes puis réduction
    */


    for(let p of pixels)
    {


        let c =
        rgb888ToRgb4(
            p.r,
            p.g,
            p.b
        );


        let found =
        false;



        for(let e of colors)
        {


            if(
                e.r===c.r &&
                e.g===c.g &&
                e.b===c.b
            )
            {

                found=true;
                break;

            }


        }



        if(!found)
        {

            colors.push(c);

        }



    }



    /*
       Si trop de couleurs,
       on réduit par moyenne
    */


    while(
        colors.length >
        config.colors
    )
    {


        let reduced=[];



        let step =
        colors.length /
        config.colors;



        for(
            let i=0;
            i<config.colors;
            i++
        )
        {


            let index =
            Math.floor(
                i*step
            );


            reduced.push(
                colors[index]
            );


        }



        colors =
        reduced;



    }





    /*
       Complète jusqu'à 32
    */


    while(
        colors.length <
        config.colors
    )
    {

        colors.push({

            r:0,
            g:0,
            b:0

        });

    }



  // COLOR00 réservé au noir Amiga

amigaPalette = [];

amigaPalette.push({
    r:0,
    g:0,
    b:0
});



// Ajoute les autres couleurs
for(
    let i=0;
    i<colors.length;
    i++
)
{

    if(
        colors[i].r===0 &&
        colors[i].g===0 &&
        colors[i].b===0
    )
    {
        continue;
    }


    if(
        amigaPalette.length <
        config.colors
    )
    {
        amigaPalette.push(
            colors[i]
        );
    }

}



// Complète la palette

while(
    amigaPalette.length <
    config.colors
)
{

    amigaPalette.push({

        r:0,
        g:0,
        b:0

    });

}




    displayPalette();


    log(
        "Palette : "
        +amigaPalette.length
        +" couleurs"
    );

}









// ===========================
// COULEUR LA PLUS PROCHE
// ===========================



function nearestColor(c)
{


    let best=1;

    let bestDistance=
    999999;



    for(
        let i=0;
        i<amigaPalette.length;
        i++
    )
    {


        let d =
        colorDistance(
            c,
            amigaPalette[i]
        );


        if(d < bestDistance)
        {

            bestDistance=d;

            best=i;

        }


    }


    return best;

}









// ===========================
// CONVERSION IMAGE AMIGA
// ===========================



function convertPixels()
{


    amigaPixels=[];



    for(let p of pixels)
    {


        let c =
        rgb888ToRgb4(
            p.r,
            p.g,
            p.b
        );



        let index =
        nearestColor(c);



        amigaPixels.push(index);


    }


}







// ===========================
// AFFICHAGE PALETTE HTML
// ===========================



function displayPalette()
{


    const box =
    document.getElementById(
        "paletteView"
    );


    if(!box)
        return;



    box.innerHTML="";



    amigaPalette.forEach(
        (c,index)=>
        {


            let div =
            document.createElement(
                "div"
            );



            div.className =
            "palette-color";



            div.title =
            index+
            " : $"+
            rgb4ToHex(c);



            let rgb =
            rgb4ToRgb888(c);



            div.style.background =
            "rgb("+
            rgb.r+
            ","+
            rgb.g+
            ","+
            rgb.b+
            ")";



            div.onclick =
            function()
            {

                selectPaletteColor(
                    index
                );

            };



            box.appendChild(div);


        }
    );


}







// ===========================
// EDITEUR COULEUR
// ===========================



let selectedColor=0;



function selectPaletteColor(index)
{

    selectedColor=index;


    let c =
    amigaPalette[index];


    document.getElementById(
        "editR"
    ).value=c.r;



    document.getElementById(
        "editG"
    ).value=c.g;



    document.getElementById(
        "editB"
    ).value=c.b;


}






document
.getElementById("applyColor")
.addEventListener(
"click",
function()
{


    if(
        !amigaPalette[selectedColor]
    )
        return;



    amigaPalette[selectedColor]=
    {

        r:
        Number(
        document.getElementById("editR").value
        ),


        g:
        Number(
        document.getElementById("editG").value
        ),


        b:
        Number(
        document.getElementById("editB").value
        )


    };



    displayPalette();


    convertPixels();


    drawAmigaPreview();


});








// ===========================
// APERCU AMIGA RGB4
// ===========================



function drawAmigaPreview()
{


    amigaCanvas.width =
    imageWidth;


    amigaCanvas.height =
    imageHeight;



    let img =
    amigaCtx.createImageData(
        imageWidth,
        imageHeight
    );



    for(
        let i=0;
        i<amigaPixels.length;
        i++
    )
    {


        let c =
        amigaPalette[
            amigaPixels[i]
        ];



        let rgb =
        rgb4ToRgb888(c);



        img.data[i*4]=rgb.r;

        img.data[i*4+1]=rgb.g;

        img.data[i*4+2]=rgb.b;

        img.data[i*4+3]=255;



    }



    amigaCtx.putImageData(
        img,
        0,
        0
    );


}







// ===========================
// CONVERSION GENERALE
// ===========================



function convertAmiga()
{


    generatePalette();


    convertPixels();


    drawAmigaPreview();


    updateInfo();



    log(
        "Conversion RGB4 terminée"
    );


}

/*
========================================================

 Partie 3 : Conversion Bitplanes Amiga OCS/ECS

========================================================
*/





// ===========================
// CREATION DES BITPLANES
// ===========================


function generateBitplanes()
{


    log(
        "Génération bitplanes..."
    );



    bitplanes=[];



    let depth =
    config.depth;



    let bytesPerLine =
    Math.ceil(
        imageWidth / 8
    );



    let planeSize =
    bytesPerLine *
    imageHeight;



    for(
        let p=0;
        p<depth;
        p++
    )
    {

        bitplanes[p] =
        new Uint8Array(
            planeSize
        );


    }






    /*
        Format Amiga :

        8 pixels = 1 octet

        pixel 0 -> bit 7
        pixel 7 -> bit 0

    */



    for(
        let y=0;
        y<imageHeight;
        y++
    )
    {


        for(
            let x=0;
            x<imageWidth;
            x++
        )
        {


            let color =
            amigaPixels[
                y*imageWidth+x
            ];



            for(
                let plane=0;
                plane<depth;
                plane++
            )
            {


                let bit =
                (
                    color >>
                    plane
                ) & 1;



                if(bit)
                {


                    let offset =
                    y*bytesPerLine
                    +
                    Math.floor(
                        x/8
                    );



                    let mask =
                    1 <<
                    (
                        7 -
                        (x%8)
                    );



                    bitplanes[plane]
                    [offset]
                    |= mask;


                }


            }


        }


    }



    log(
        "Bitplanes générés : "
        +
        depth
    );


}









// ===========================
// AFFICHAGE BITPLANES
// ===========================



function drawBitplanes()
{


    let canvases=[

        "plane0Canvas",
        "plane1Canvas",
        "plane2Canvas",
        "plane3Canvas",
        "plane4Canvas"

    ];



    for(
        let p=0;
        p<5;
        p++
    )
    {


        let canvas =
        document.getElementById(
            canvases[p]
        );



        if(!canvas)
            continue;



        canvas.width =
        imageWidth;



        canvas.height =
        imageHeight;



        let ctx =
        canvas.getContext(
            "2d"
        );



        let img =
        ctx.createImageData(
            imageWidth,
            imageHeight
        );



        if(
            p>=bitplanes.length
        )
        {

            ctx.putImageData(
                img,
                0,
                0
            );

            continue;

        }





        let bytesPerLine =
        Math.ceil(
            imageWidth/8
        );



        for(
            let y=0;
            y<imageHeight;
            y++
        )
        {


            for(
                let x=0;
                x<imageWidth;
                x++
            )
            {


                let offset =
                y*bytesPerLine
                +
                Math.floor(
                    x/8
                );



                let mask =
                1 <<
                (
                    7 -
                    x%8
                );



                let value =
                bitplanes[p]
                [offset]
                &
                mask;



                let index =
                (
                    y*imageWidth+x
                )*4;



                if(value)
                {

                    img.data[index]=255;

                    img.data[index+1]=255;

                    img.data[index+2]=255;

                }
                else
                {

                    img.data[index]=0;

                    img.data[index+1]=0;

                    img.data[index+2]=0;

                }


                img.data[index+3]=255;


            }


        }



        ctx.putImageData(
            img,
            0,
            0
        );


    }



}









// ===========================
// FORMAT RAW PLANAR
// ===========================



function createRawPlanar()
{


    let totalSize=0;



    for(
        let p of bitplanes
    )
    {

        totalSize +=
        p.length;

    }



    let raw =
    new Uint8Array(
        totalSize
    );



    let offset=0;



    for(
        let p of bitplanes
    )
    {


        raw.set(
            p,
            offset
        );


        offset +=
        p.length;


    }



    return raw;


}








// ===========================
// FORMAT RAW INTERLEAVED
// ===========================



function createRawInterleaved()
{


    let bytesPerLine =
    Math.ceil(
        imageWidth/8
    );


    let planeSize =
    bytesPerLine *
    imageHeight;



    let raw =
    new Uint8Array(
        planeSize *
        bitplanes.length
    );



    let offset=0;



    for(
        let y=0;
        y<imageHeight;
        y++
    )
    {


        for(
            let plane=0;
            plane<bitplanes.length;
            plane++
        )
        {


            let start =
            y*bytesPerLine;



            for(
                let b=0;
                b<bytesPerLine;
                b++
            )
            {


                raw[offset++]=
                bitplanes[plane]
                [
                    start+b
                ];

            }


        }


    }



    return raw;


}









// ===========================
// GENERATION RAW
// ===========================



function generateRAW()
{


    if(
        config.interleaved
    )
    {

        rawData =
        createRawInterleaved();

    }
    else
    {

        rawData =
        createRawPlanar();

    }



    log(
        "RAW créé : "
        +
        rawData.length
        +
        " octets"
    );



}









// ===========================
// MISE A JOUR COMPLETE
// ===========================



function generateGraphics()
{


    generateBitplanes();


    drawBitplanes();


    generateRAW();



}

/*
========================================================

 Partie 4 : Générateur Copper List Amiga

========================================================
*/





// ===========================
// RGB4 -> VALEUR COPPER
// ===========================


function rgb4ToWord(c)
{


    return (

        (c.r << 8) |
        (c.g << 4) |
        c.b

    );


}





function rgb4ToAsm(c)
{


    let value =
    rgb4ToWord(c);



    return "$"
        +
        value
        .toString(16)
        .padStart(3,"0")
        .toUpperCase();


}







// ===========================
// GENERATION COULEURS COPPER
// ===========================


function generateCopperColors()
{


    let lines=[];



    lines.push(
        "; Copper List Amiga"
    );


    lines.push(
        "; Palette RGB4"
    );


    lines.push("");



    for(
        let i=0;
        i<amigaPalette.length;
        i++
    )
    {


        let c =
        amigaPalette[i];



        let value =
        rgb4ToAsm(c);



        if(
            config.copperFormat
            ===
            "asm"
        )
        {


            lines.push(

                "dc.w COLOR"
                +
                i
                .toString()
                .padStart(2,"0")
                +
                ","
                +
                value

            );


        }
        else
        {


            lines.push(

                "COLOR"
                +
                i
                .toString()
                .padStart(2,"0")
                +
                ","
                +
                value

            );


        }


    }




    lines.push("");



    lines.push(
        "; Fin Copper"
    );



    if(
        config.copperFormat
        ===
        "asm"
    )
    {


        lines.push(
            "dc.w $FFFF,$FFFE"
        );


    }
    else
    {

        lines.push(
            "$FFFF,$FFFE"
        );

    }



    return lines.join("\n");


}








// ===========================
// COPPER COMPLET AVEC REGISTRES
// ===========================



function generateFullCopper()
{


    let lines=[];



    if(
        config.copperFormat
        ===
        "asm"
    )
    {

        lines.push(
            ";================================"
        );

        lines.push(
            "; AMIGA 500 COPPER LIST"
        );

        lines.push(
            ";================================"
        );

        lines.push("");




        lines.push(
            "dc.w DIWSTRT,$"
            +
            getRegisterValue("diwstrt")
        );


        lines.push(
            "dc.w DIWSTOP,$"
            +
            getRegisterValue("diwstop")
        );


        lines.push(
            "dc.w DDFSTRT,$"
            +
            getRegisterValue("ddfstrt")
        );


        lines.push(
            "dc.w DDFSTOP,$"
            +
            getRegisterValue("ddfstop")
        );



        lines.push("");



    }



    lines.push(
        generateCopperColors()
    );



    return lines.join("\n");


}








function getRegisterValue(id)
{


    let value =
    document.getElementById(id);



    if(!value)
        return "0000";



    return value.value
    .replace("$","")
    .toUpperCase();


}








// ===========================
// GENERATION COPPER
// ===========================



function generateCopper()
{


    if(
        !config.copper
    )
    {

        copperText="";
        return;

    }



    copperText =
    generateFullCopper();



    if(copperPreview)
    {

        copperPreview.value =
        copperText;

    }



    log(
        "Copper générée : "
        +
        copperText.length
        +
        " caractères"
    );



}







// ===========================
// TAILLE COPPER MEMOIRE
// ===========================



function updateMemoryInfo()
{


    let paletteBytes =
    amigaPalette.length *
    2;



    let bitmapBytes =
    rawData.length;



    let copperBytes =
    Math.ceil(
        copperText.length/4
    );



    let paletteSize =
    document.getElementById(
        "paletteSize"
    );


    let bitmapSize =
    document.getElementById(
        "bitmapSize"
    );


    let copperSize =
    document.getElementById(
        "copperSize"
    );



    let totalMemory =
    document.getElementById(
        "totalMemory"
    );



    if(paletteSize)
        paletteSize.textContent =
        paletteBytes+" octets";


    if(bitmapSize)
        bitmapSize.textContent =
        bitmapBytes+" octets";


    if(copperSize)
        copperSize.textContent =
        copperBytes+" octets";


    if(totalMemory)
        totalMemory.textContent =
        (
            paletteBytes+
            bitmapBytes+
            copperBytes
        )
        +
        " octets";


}








// ===========================
// GENERATION COMPLETE
// ===========================



function buildAmigaData()
{


    generateGraphics();


    generateCopper();


    updateMemoryInfo();



    setStatus(
        "Conversion terminée"
    );


}
/*
========================================================

 Partie 5 : Exports fichiers Amiga

========================================================
*/






// ===========================
// CREATION FICHIER
// ===========================



function downloadFile(
    filename,
    data,
    mime
)
{


    let blob =
    new Blob(
        [
            data
        ],
        {
            type:mime
        }
    );



    let url =
    URL.createObjectURL(
        blob
    );



    let a =
    document.createElement(
        "a"
    );


    a.href=url;

    a.download=filename;


    document.body.appendChild(a);


    a.click();


    document.body.removeChild(a);



    setTimeout(
        function()
        {

            URL.revokeObjectURL(
                url
            );

        },
        1000
    );


}









// ===========================
// EXPORT RAW
// ===========================



function exportRAW()
{


    if(
        rawData.length===0
    )
    {

        buildAmigaData();

    }



    downloadFile(

        imageName+
        ".raw",

        rawData,

        "application/octet-stream"

    );



    log(
        "Export RAW terminé"
    );



}







// ===========================
// EXPORT COP
// ===========================



function exportCOP()
{


    if(
        copperText.length===0
    )
    {

        generateCopper();

    }



    downloadFile(

        imageName+
        ".cop",

        copperText,

        "text/plain"

    );



    log(
        "Export COP terminé"
    );



}







// ===========================
// EXPORT ASM
// ===========================



function generateASM()
{


    let asm=[];



    asm.push(
        ";================================"
    );


    asm.push(
        "; "
        +
        imageName
    );


    asm.push(
        "; Generated by Amiga Graphic Studio"
    );


    asm.push(
        ";================================"
    );


    asm.push("");



    asm.push(
        imageName+
        "_bitmap:"
    );



    for(
        let i=0;
        i<rawData.length;
        i++
    )
    {


        if(
            i%16===0
        )
        {

            asm.push(
                "    dc.b "
            );

        }



        asm[
            asm.length-1
        ] +=

        "$"
        +
        rawData[i]
        .toString(16)
        .padStart(2,"0")
        .toUpperCase();



        if(
            i!==rawData.length-1
        )
        {

            asm[
                asm.length-1
            ] += ",";

        }


    }



    asm.push("");

    asm.push(
        copperText
    );



    return asm.join("\n");

}








function exportASM()
{


    buildAmigaData();



    downloadFile(

        imageName+
        ".asm",

        generateASM(),

        "text/plain"

    );


    log(
        "Export ASM terminé"
    );



}








// ===========================
// EXPORT C
// ===========================



function generateC()
{


    let c=[];



    c.push(
        "/* Generated Amiga data */"
    );


    c.push(
        "#include <stdint.h>"
    );


    c.push("");



    c.push(
        "const uint8_t "
        +
        imageName
        +
        "_raw[] = {"
    );



    for(
        let i=0;
        i<rawData.length;
        i++
    )
    {


        if(
            i%12===0
        )
        {

            c.push("");

        }



        c[
            c.length-1
        ] +=

        "0x"
        +
        rawData[i]
        .toString(16)
        .padStart(2,"0")
        .toUpperCase()
        +
        ",";


    }



    c.push("");

    c.push(
        "};"
    );



    return c.join("\n");


}







function exportC()
{


    buildAmigaData();



    downloadFile(

        imageName+
        ".c",

        generateC(),

        "text/plain"

    );

}









// ===========================
// EXPORT HEADER H
// ===========================



function generateHeader()
{


    let h=[];



    h.push(
        "#ifndef "
        +
        imageName.toUpperCase()
        +
        "_H"
    );


    h.push(
        "#define "
        +
        imageName.toUpperCase()
        +
        "_H"
    );


    h.push("");



    h.push(
        "extern const unsigned char "
        +
        imageName
        +
        "_raw[];"
    );


    h.push("");



    h.push(
        "#endif"
    );



    return h.join("\n");

}







function exportHeader()
{


    downloadFile(

        imageName+
        ".h",

        generateHeader(),

        "text/plain"

    );


}








// ===========================
// EXPORT PALETTE
// ===========================



function generatePaletteASM()
{


    let out=[];



    out.push(
        "; Palette RGB4"
    );


    out.push("");



    amigaPalette.forEach(
        (c,i)=>
        {


            out.push(

                "dc.w COLOR"
                +
                i
                .toString()
                .padStart(2,"0")
                +
                ","
                +
                rgb4ToAsm(c)

            );


        }
    );



    return out.join("\n");


}







function exportPalette()
{


    downloadFile(

        imageName+
        ".pal",

        generatePaletteASM(),

        "text/plain"

    );


}









// ===========================
// BOUTONS
// ===========================



document
.getElementById("exportRaw")
.onclick =
exportRAW;



document
.getElementById("btnRaw")
.onclick =
exportRAW;



document
.getElementById("exportCop")
.onclick =
exportCOP;



document
.getElementById("btnCop")
.onclick =
exportCOP;



document
.getElementById("exportAsm")
.onclick =
exportASM;



document
.getElementById("btnAsm")
.onclick =
exportASM;



document
.getElementById("exportC")
.onclick =
exportC;



document
.getElementById("exportHeader")
.onclick =
exportHeader;



document
.getElementById("exportPalette")
.onclick =
exportPalette;

/*
========================================================

 Partie 6 : Interface, options et initialisation

========================================================
*/


function redrawCanvases()
{
    if(!sourceImage)
        return;


    originalCtx.clearRect(
        0,
        0,
        imageWidth,
        imageHeight
    );


    originalCtx.drawImage(
        sourceImage,
        0,
        0
    );


    drawAmigaPreview();


    if(showGrid)
    {
        drawAmigaGrid(originalCtx);
        drawAmigaGrid(amigaCtx);
    }
}



// ===========================
// INITIALISATION
// ===========================



// ===========================
// OPTIONS BITPLANES
// ===========================


depthSelect.addEventListener(
"change",
function()
{


    config.depth =
    Number(
        this.value
    );



    log(
        "Depth = "
        +
        config.depth
        +
        " bitplanes"
    );



    if(sourceImage)
        buildAmigaData();



});







// ===========================
// OPTIONS COULEURS
// ===========================


colorSelect.addEventListener(
"change",
function()
{


    config.colors =
    Number(
        this.value
    );



    if(sourceImage)
    {

        convertAmiga();

        buildAmigaData();

    }


});








// ===========================
// MODE MEMOIRE
// ===========================



document
.getElementById("planarMode")
.addEventListener(
"change",
function()
{

    config.interleaved=false;

    if(sourceImage)
        generateGraphics();

});





document
.getElementById("interleavedMode")
.addEventListener(
"change",
function()
{

    config.interleaved=true;


    if(sourceImage)
        generateGraphics();


});









// ===========================
// COPPER
// ===========================



document
.getElementById("enableCopper")
.addEventListener(
"change",
function()
{


    config.copper =
    this.checked;



    if(sourceImage)
        generateCopper();


});








document
.getElementById("copperFormat")
.addEventListener(
"change",
function()
{


    config.copperFormat =
    this.value;



    if(sourceImage)
        generateCopper();


});








document
.getElementById("rgbMode")
.addEventListener(
"change",
function()
{


    config.rgbMode =
    this.value;



    if(sourceImage)
        generateCopper();


});









// ===========================
// PICCON
// ===========================



document
.getElementById("picconMode")
.addEventListener(
"change",
function()
{


    log(
        "Mode PicCon : "
        +
        this.checked
    );


});








// ===========================
// ZOOM CANVAS
// ===========================



document
.getElementById("zoomSelect")
.addEventListener(
"change",
function()
{


    let zoom =
    Number(
        this.value
    );



    originalCanvas.style.width =
    (
        imageWidth *
        zoom
    )
    +"px";



    originalCanvas.style.height =
    (
        imageHeight *
        zoom
    )
    +"px";



    amigaCanvas.style.width =
    (
        imageWidth *
        zoom
    )
    +"px";


    amigaCanvas.style.height =
    (
        imageHeight *
        zoom
    )
    +"px";



});







// ===========================
// GRILLE AMIGA 8x8 PIXELS
// ===========================

function drawPixelGrid(ctx)
{

    ctx.save();


    ctx.strokeStyle =
    "rgba(0,255,80,0.25)";


    ctx.lineWidth =
    1;



    // grille verticale tous les 8 pixels

    for(
        let x=0;
        x<=imageWidth;
        x+=8
    )
    {

        ctx.beginPath();

        ctx.moveTo(
            x+0.5,
            0
        );

        ctx.lineTo(
            x+0.5,
            imageHeight
        );

        ctx.stroke();

    }




    // grille horizontale tous les 8 pixels

    for(
        let y=0;
        y<=imageHeight;
        y+=8
    )
    {

        ctx.beginPath();

        ctx.moveTo(
            0,
            y+0.5
        );

        ctx.lineTo(
            imageWidth,
            y+0.5
        );

        ctx.stroke();

    }



    ctx.restore();

}










// ===========================
// BOUTON RELOAD
// ===========================



document
.getElementById("btnReload")
.onclick =
function()
{

    if(sourceImage)
    {

        convertAmiga();

        buildAmigaData();

    }


};









// ===========================
// MISE A JOUR COMPLETE
// ===========================



function refreshAll()
{


    if(!sourceImage)
        return;



    convertAmiga();


    buildAmigaData();



}









// ===========================
// INITIALISATION
// ===========================



window.onload =
function()
{


    log(
        "--------------------------------"
    );


    log(
        "AMIGA GRAPHIC STUDIO READY"
    );


    log(
        "A500 OCS/ECS 5 bitplanes"
    );


    log(
        "PNG converter initialized"
    );


    setStatus(
        "Prêt"
    );

const gridCheck = document.getElementById("gridCheck");

if(gridCheck)
{
    gridCheck.addEventListener(
        "change",
        function()
        {
            showGrid = this.checked;

            if(sourceImage)
            {
                redrawCanvases();
            }
        }
    );
}




};



