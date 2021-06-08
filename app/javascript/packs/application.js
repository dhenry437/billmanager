// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
require('jquery')

// Bootstrap form validation rework
$(document).on('turbolinks:load', function () {
    $('form :submit').each(function () { // dont know why i have to do this but i couldn't catch the submit event before rails took over
        let form = $(this).parents('form')[0];

        $(this).on('click', function (e) {
            if (!form.checkValidity()) {
                e.preventDefault();
                e.stopPropagation();
            }

            form.classList.add('was-validated')
        });
    });
});

Rails.start()
Turbolinks.start()
ActiveStorage.start()
