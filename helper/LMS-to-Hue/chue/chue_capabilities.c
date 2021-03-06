/*
 *  chue - philips hue library for C
 *
 *  (c) Rouven Weiler 2017
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#define _GNU_SOURCE

#include <string.h>

#include "jansson.h"

#include "chue_capabilities.h"
#include "chue_log.h"

static chue_loglevel_t *clp = &chue_loglevel;


/**
 * @desc Gets the configuration of the hue bridge
 *
 * @param pointer to a variable of type chue_bridge_t
 * @return 0 for success or 1 for error
 */
extern int chue_get_all_capabilities(chue_bridge_t *bridge) {

    json_t *root, *available, *lights, *data, *chue_error;
    json_error_t error;
	chue_request_t request;
	chue_response_t response;

	if (chue_connect(bridge)) {
		return 1;
	}

	request.method = _GET;

	snprintf(request.uri, CHUE_STR_LEN,
        "/api/%s/capabilities",
        bridge->user_name
	);

	// send empty body for getting the configuration
	request.body = "";

	chue_send_request(bridge, &request);
	chue_receive_response(bridge, &response);

	chue_disconnect(bridge);

	root = json_loads(response.body, 0, &error);
	if (response.body) free(response.body);

	if (!root) {
		CHUE_ERROR("Error root.\n");
		return 1;
	}

	if (json_is_array(root)) {

		data = json_array_get(root, 0);
		chue_error = json_object_get(data, "error");
		json_object_get(chue_error, "description");

		json_decref(root);
		return 1;
	}

	if (json_is_object(root)) {
		lights = json_object_get(root, "lights");
		available = json_object_get(lights, "available");
		bridge->capabilities.avail_lights = json_integer_value(available);

		//printf("Available lights: %d\n", bridge->capabilities.lights);

	}

	json_decref(root);

	return 0;
}
