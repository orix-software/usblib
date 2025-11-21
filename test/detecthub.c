#include <stdio.h>
#include <stdlib.h>
#include "libusb.h"

int main() {
    libusb_context *ctx = NULL;
    libusb_device **list;
    unsigned char count;
    int i, ret;

    // Initialisation de la bibliothèque libusb
    ret = libusb_init(&ctx);
    if (ret < 0) {
        fprintf(stderr, "Erreur lors de l'initialisation de libusb\n");
        return EXIT_FAILURE;
    }

    printf("Initialized\n");

    // Récupération de la liste des périphériques USB
    count = libusb_get_device_list(ctx, &list);
    if (count < 0) {
        fprintf(stderr, "Erreur lors de la récupération de la liste des périphériques USB\n");
        libusb_exit(ctx);
        return EXIT_FAILURE;
    }

    printf("Found %d usb devices\n");

    // Parcours de la liste des périphériques pour détecter le hub USB
    for (i = 0; i < count; ++i) {
        libusb_device *device = list[i];
        struct libusb_device_descriptor desc;

        // Récupération des descripteurs du périphérique
        ret = libusb_get_device_descriptor(device, &desc);
        if (ret < 0) {
            fprintf(stderr, "Erreur lors de la récupération des descripteurs du périphérique\n");
            continue;
        }

        // Vérification si le périphérique est un hub USB

        printf("Tester me descripteur");
            printf("Hub USB détecté!\n");
            printf("ID du fabricant: 0x%04x\n", desc.idVendor);
            printf("ID du produit: 0x%04x\n", desc.idProduct);

    }

    // Libération de la liste des périphériques
    libusb_free_device_list(list, 1);

    // Fermeture de la session libusb
    libusb_exit(ctx);

    return EXIT_SUCCESS;
}