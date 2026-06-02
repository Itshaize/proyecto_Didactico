/**
 * EnglishKids – scene3d.js
 * Escena Three.js para mostrar modelos 3D de palabras
 */

'use strict';

var Scene3D = (function () {

    var scene, camera, renderer, model, animFrameId;
    var isRunning = false;

    /**
     * Inicializa la escena 3D en el canvas indicado.
     * @param {string} canvasId  – ID del elemento <canvas>
     * @param {string} modelPath – Ruta al modelo .glb (opcional)
     * @param {string} word      – Palabra en inglés (para figura de texto 3D)
     */
    function init(canvasId, modelPath, word) {
        var canvas = document.getElementById(canvasId);
        if (!canvas) return;

        // Verificar que Three.js está disponible
        if (typeof THREE === 'undefined') {
            console.warn('Three.js no está disponible. Mostrando vista alternativa.');
            showFallback(canvas, word);
            return;
        }

        scene    = new THREE.Scene();
        scene.background = new THREE.Color(0xF0F8FF);

        // Cámara
        var w = canvas.clientWidth  || 400;
        var h = canvas.clientHeight || 300;
        camera = new THREE.PerspectiveCamera(45, w / h, 0.1, 100);
        camera.position.set(0, 1.5, 4);

        // Renderer
        renderer = new THREE.WebGLRenderer({ canvas: canvas, antialias: true });
        renderer.setSize(w, h);
        renderer.setPixelRatio(window.devicePixelRatio);
        renderer.shadowMap.enabled = true;

        // Iluminación
        var ambient = new THREE.AmbientLight(0xffffff, 0.7);
        scene.add(ambient);

        var dirLight = new THREE.DirectionalLight(0xffffff, 1);
        dirLight.position.set(5, 10, 7);
        dirLight.castShadow = true;
        scene.add(dirLight);

        var pointLight = new THREE.PointLight(0x4FC3F7, 0.8, 20);
        pointLight.position.set(-3, 3, 3);
        scene.add(pointLight);

        // Cargar modelo .glb si existe, si no, crear geometría procedural
        if (modelPath && typeof THREE.GLTFLoader !== 'undefined') {
            loadGLTF(modelPath, word);
        } else {
            createProceduralObject(word);
        }

        isRunning = true;
        animate();
    }

    function loadGLTF(path, word) {
        var loader = new THREE.GLTFLoader();
        loader.load(
            path,
            function (gltf) {
                model = gltf.scene;
                model.scale.set(1.5, 1.5, 1.5);
                scene.add(model);
            },
            undefined,
            function (err) {
                console.warn('Error cargando GLB:', err);
                createProceduralObject(word);
            }
        );
    }

    function createProceduralObject(word) {
        // Objeto 3D de relleno: esfera con textura de color según palabra
        var colorMap = {
            'red': 0xFF5252, 'blue': 0x448AFF, 'green': 0x69F0AE,
            'yellow': 0xFFD740, 'purple': 0xE040FB, 'orange': 0xFF6D00,
            'pink': 0xF48FB1, 'black': 0x212121, 'white': 0xECEFF1,
            'brown': 0x795548
        };

        var lword = (word || '').toLowerCase();
        var color = colorMap[lword] || 0x4FC3F7;

        var geometry = new THREE.SphereGeometry(1.2, 32, 32);
        var material = new THREE.MeshPhongMaterial({
            color: color,
            shininess: 80,
            specular: new THREE.Color(0xffffff)
        });
        model = new THREE.Mesh(geometry, material);
        model.castShadow = true;
        scene.add(model);

        // Anillo decorativo
        var ringGeo = new THREE.TorusGeometry(1.8, 0.08, 8, 64);
        var ringMat = new THREE.MeshPhongMaterial({ color: 0xFFD54F, shininess: 100 });
        var ring = new THREE.Mesh(ringGeo, ringMat);
        ring.rotation.x = Math.PI / 4;
        scene.add(ring);
    }

    function animate() {
        if (!isRunning) return;
        animFrameId = requestAnimationFrame(animate);

        if (model) {
            model.rotation.y += 0.012;
            model.rotation.x += 0.003;
        }

        renderer.render(scene, camera);
    }

    function destroy() {
        isRunning = false;
        if (animFrameId) cancelAnimationFrame(animFrameId);
        if (renderer) renderer.dispose();
    }

    function showFallback(canvas, word) {
        var parent = canvas.parentElement;
        if (parent) {
            var div = document.createElement('div');
            div.style.cssText = 'display:flex;align-items:center;justify-content:center;' +
                                'width:100%;height:100%;background:linear-gradient(135deg,#4FC3F7,#81C784);' +
                                'border-radius:16px;font-family:Fredoka One,cursive;font-size:4rem;color:#fff;' +
                                'text-shadow:0 4px 12px rgba(0,0,0,0.2);';
            div.textContent = (word || '?').charAt(0).toUpperCase();
            canvas.replaceWith(div);
        }
    }

    return {
        init: init,
        destroy: destroy
    };
})();
