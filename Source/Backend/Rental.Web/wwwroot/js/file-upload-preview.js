(function() {
    var stores = {};

    window.initFileUploadPreview = function (inputId, listId) {
        debugger;
        stores[inputId] = [];
        var input = document.getElementById(inputId);
        if (!input) return;
        input.addEventListener('change', function() {
            var files = this.files;
            for (var i = 0; i < files.length; i++) {
                stores[inputId].push(files[i]);
            }
            renderList(inputId, listId);
            this.value = '';
        });
    };

    window.removeFileFromStore = function(inputId, listId, index) {
        stores[inputId].splice(index, 1);
        renderList(inputId, listId);
    };

    function renderList(inputId, listId) {
        var list = document.getElementById(listId);
        if (!list) return;
        list.innerHTML = '';
        var store = stores[inputId] || [];
        store.forEach(function(file, idx) {
            var div = document.createElement('div');
            div.className = 'flex items-center justify-between px-3 py-2 bg-gray-50 rounded-lg text-sm';
            var icon = 'fa-file';
            if (file.type.startsWith('image/')) icon = 'fa-file-image text-green-500';
            else if (file.type.includes('pdf')) icon = 'fa-file-pdf text-red-500';
            else if (file.type.includes('word') || file.type.includes('document')) icon = 'fa-file-word text-blue-500';
            else if (file.type.includes('sheet') || file.type.includes('excel')) icon = 'fa-file-excel text-green-600';
            div.innerHTML =
                '<div class="flex items-center min-w-0 flex-1">' +
                    '<i class="fas ' + icon + ' mr-2"></i>' +
                    '<span class="truncate">' + file.name + '</span>' +
                    '<span class="ml-2 text-xs text-gray-400">(' + formatSize(file.size) + ')</span>' +
                '</div>' +
                '<button type="button" onclick="removeFileFromStore(\'' + inputId + '\',\'' + listId + '\',' + idx + ')" class="text-red-500 hover:text-red-700 ml-2 flex-shrink-0">' +
                    '<i class="fas fa-times"></i>' +
                '</button>';
            list.appendChild(div);
        });
        rebuildInput(inputId);
    }

    function rebuildInput(inputId) {
        var dt = new DataTransfer();
        var store = stores[inputId] || [];
        store.forEach(function(f) { dt.items.add(f); });
        var input = document.getElementById(inputId);
        if (input) input.files = dt.files;
    }

    function formatSize(bytes) {
        if (bytes < 1024) return bytes + ' B';
        if (bytes < 1048576) return (bytes / 1024).toFixed(1) + ' KB';
        return (bytes / 1048576).toFixed(1) + ' MB';
    }
})();
