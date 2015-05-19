var xmlhttp;
if (window.XMLHttpRequest) {
    // code for IE7+, Firefox, Chrome, Opera, Safari
    xmlhttp=new XMLHttpRequest();
} else {
    // code for IE6, IE5
    xmlhttp=new ActiveXObject("Microsoft.XMLHTTP");
}
if (xmlhttp != undefined) {
    var reload_interval = 500;
    var lastModified = document.lastModified;
    function reload_if_needed() {
        xmlhttp.open('GET', window.location.pathname + "?" + (new Date()).getMilliseconds(), true);
        xmlhttp.onreadystatechange = function() {
            if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
                if (xmlhttp.responseXML.lastModified != lastModified) {
                    location.reload();
                }
            }
        };
        xmlhttp.send();
        setTimeout(reload_if_needed, reload_interval);
    }
    setTimeout(reload_if_needed, reload_interval);
}
