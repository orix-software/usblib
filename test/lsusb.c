#include <stdio.h>
#include "libusb.h"

int main() {
    unsigned char count;
    unsigned char i;
    libusb_device **devices;
    // Initialisation de libusb
    libusb_init(NULL);

    // Récupération de la liste des périphériques USB

    count = libusb_get_device_list(NULL, &devices);

    if (count < 0) {
        printf("Erreur lors de la récupération de la liste des périphériques USB\n");
        return 1;
    }

    printf("Périphériques USB trouvés : %zd\n", count);

    // Parcours de la liste des périphériques et affichage d'informations
    for ( i = 0; i < count; ++i) {
        //libusb_device *device = devices[i];
        //struct libusb_device_descriptor descriptor;
/*
        if (libusb_get_device_descriptor(device, &descriptor) == 0) {
            printf("ID du fournisseur: %04x, ID du produit: %04x\n",
                   descriptor.idVendor, descriptor.idProduct);
        }
    */
    }

    // Libération de la liste des périphériques
    //libusb_free_device_list(devices, 1);

    // Fermeture de libusb
    libusb_exit(NULL);

    return 0;
}