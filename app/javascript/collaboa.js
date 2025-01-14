// =============================================================================
// Event listeners
// =============================================================================

function confirmClick(element) {
  element.addEventListener('click', function(event) {
    event.preventDefault();
    event.stopPropagation();

    const proceed = window.confirm(element.dataset.confirm);

    if (proceed) {
      if (element.href) {
        window.location.href = element.href;
      } else {
        const presumedFormElement = element.parentNode;
        presumedFormElement.submit();
      }
    };
  });
}

// =============================================================================
// Event listener additions
// =============================================================================

document.addEventListener('DOMContentLoaded', function(event) {
  const confirmationElements = document.querySelectorAll('[data-confirm]');

  confirmationElements.forEach(function(confirmationElement, confirmationElementIndex, listObject) {
    confirmClick(confirmationElement);
  });
});

// =============================================================================
// Miscellaneous
// =============================================================================

// Pass the HTML ID of an item used to toggle a section's visibility, so it can
// have CSS classes added/removed to indicate the section state; and the ID of
// the show-hide section itself, toggling CSS 'display' to "block" or "none".
//
function toggleVisibility(togglerId, toggleeId) {
  const togglerElement = document.getElementById(togglerId);
  const toggleeElement = document.getElementById(toggleeId);

  if (toggleeElement.style.display == 'none') {
    toggleeElement.style.display = 'block';
    togglerElement.classList.add('toggle-shown');

  } else {
    toggleeElement.style.display = 'none';
    togglerElement.classList.remove('toggle-shown');
  }
}

function toggleChanges() {
  if (document.getElementById("changes").style.display == "none") {
    document.getElementById("changes").style.display  = "block";
    document.getElementById("revision").style.display = "none";
    document.getElementById("show_changes").style.display  = "none";
    document.getElementById("hide_changes").style.display = "inline";
  } else {
    document.getElementById("changes").style.display  = "none";
    document.getElementById("revision").style.display = "block";
    document.getElementById("show_changes").style.display  = "inline";
    document.getElementById("hide_changes").style.display = "none";
  }
}

function toggleInputSize(id) {
  if (document.getElementById(id).className == "smalltextarea") {
    document.getElementById(id).className = "largetextarea";
    document.getElementById('toggleinputsize').innerHTML
                        = '<a href="javascript:toggleInputSize(\''+id+'\')">mindre textfält</a>';
  } else {
    document.getElementById(id).className = "smalltextarea";
    document.getElementById('toggleinputsize').innerHTML
                        = '<a href="javascript:toggleInputSize(\''+id+'\')">större textfält</a>';
  }
}

function switch_category(selectobj)
{
	var category_id = selectobj.options[selectobj.selectedIndex].value;
	var url = new String(window.location);
	cleanurl = url.replace(/\?\w+=\d+/, "");
	cleanurl = cleanurl.replace(/\d+$/, "");

	if(category_id != "") {
	  // check for slash at end
	  lastchar = cleanurl.substr(cleanurl.length - 1);
	  if (lastchar != "/") {
	    loc = cleanurl + '/' + category_id;
	  } else {
	    loc = cleanurl + category_id;
	  }
	} else {
	  loc = cleanurl;
	}
	window.location = loc;
}
