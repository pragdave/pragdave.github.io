// if the window hash matches a media item on the page, promote it
// to the top


$(function () {
    if ($(".speak")) {
        var hash = window.location.hash;
        if (hash) {
            var $small_element = $(hash);
            if ($small_element) {
                $small_element.hide();
                var $showcase = $(".showcase");
                var $holder = $showcase.find("#holder");
                $holder.html($small_element.html());
                $holder.addClass($small_element.attr("class"));
                $showcase.show(500);
                $(window).scrollTop(0);
            }
        }
    }
});
