document.addEventListener('DOMContentLoaded', () => {
    {
        const selectElements = document.querySelectorAll('select[data-items]');
        selectElements.forEach(selectElement => {
            initDynamicSelect(selectElement);
        });
    }
    {
        const actionButtons = document.querySelectorAll('button[data-endpoint]');
        actionButtons.forEach(button => {
            initDynamicButton(button);
        });
    }
});

async function initDynamicSelect(selectElement) {
    const itemsUrl = `/${selectElement.dataset.items}`;
    const selectedUrl = `/${selectElement.dataset.selected_item}`;
    
    const statusElement = selectElement.parentElement.querySelector('.status');
    
    let loadedItems = [];

    try {
        if (statusElement) statusElement.textContent = 'Lade Daten...';

        const [itemsResponse, selectedResponse] = await Promise.all([
            fetchSafe(itemsUrl),
            fetchSafe(selectedUrl)
        ]);

        loadedItems = await itemsResponse.json();
        const selectedItem = await selectedResponse.json();

        // Rebuild dropdown options with the loaded data
        populateOptions(selectElement, loadedItems);

        selectElement.value = selectedItem;
        if (statusElement) statusElement.textContent = `Active: "${selectedItem}"`;
    } catch (error) {
        console.error(`Error at endpoint ${itemsUrl}:`, error);
        if (statusElement) statusElement.textContent = 'Error loading data';
    }

    // React on user selection
    selectElement.addEventListener('change', async (event) => {
        const chosenId = event.target.value;
        try {
            if (statusElement) statusElement.textContent = 'Saving selection...';

            const response = await fetchSafe(selectedUrl, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(chosenId)
            });

            if (statusElement) statusElement.textContent = 'Selection saved';
        } catch (error) {
            console.error(`Error saving to ${selectedUrl}:`, error);
            if (statusElement) statusElement.textContent = 'Error storing selection';
        }
    });
}

/**
 * Writes <option> tags into a select element
 */
function populateOptions(selectElement, items) {
    selectElement.innerHTML = '';

    items.forEach(item => {
        const option = document.createElement('option');
        option.value = item.id;
        option.textContent = item.title;
        selectElement.appendChild(option);
    });
}

async function initDynamicButton(button) {
    button.addEventListener('click', async (event) => {
        const endpointUrl = `/${button.dataset.endpoint}`;
        
        // Deactivate button during the request
        button.disabled = true;
        const originalText = button.textContent;
        button.textContent = 'Loading...';

        try {
            // Send POST request
            const response = await fetchSafe(endpointUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            });
        } catch (error) {
            console.error(`Error invoking endpoint ${endpointUrl}:`, error);
        } finally {
            button.disabled = false;
            button.textContent = originalText;
        }
    });
}

async function fetchSafe(url, options = {}) {
    // Forward parameters exactly like standard fetch
    const response = await fetch(url, options);

    // Checks if the status is exactly 200 and within the response.ok range (200-299)
    if (!response.ok || response.status !== 200) {
        // Optional: Try to parse JSON error message from the server if it exists
        let serverMessage = '';
        try {
            const errorData = await response.json();
            serverMessage = errorData.message || JSON.stringify(errorData);
        } catch {
            // Fallback if response body is not JSON or is empty
            serverMessage = response.statusText || 'Unknown Error';
        }

        throw new Error(`Fetch failed! Status: ${response.status} (${serverMessage})`);
    }

    return response;
}
