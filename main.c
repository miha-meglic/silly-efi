#include <efi.h>
#include <efilib.h>

EFI_STATUS EFIAPI efi_main(EFI_HANDLE IH, EFI_SYSTEM_TABLE *ST) {
    InitializeLib(IH, ST);

    // Clear screen
    //for (int i = 0; i < 60; ++i) Print(L"\n");
    uefi_call_wrapper(ST->ConOut->ClearScreen, 1, ST->ConOut);

    // Print name
    Print(L"Miha Meglic");

    // Cat animation
    CHAR16* cat_frames[] = {
        L"  /\\_/\\  \n ( o.o ) \n  > ^ <  ",
        L"  /\\_/\\  \n ( -.- ) \n  > ^ <  ",
        L"  /\\_/\\  \n ( o.o ) \n  > v <  ",
        L"  /\\_/\\  \n ( o.o ) \n  > ^ <  "
    };
    int num_frames = sizeof(cat_frames) / sizeof(cat_frames[0]);

    // Print animation in a loop
    while (1) {
	for (int i = 0; i < num_frames; ++i) {
	    IPrintAt(ST->ConOut, 0, 2, cat_frames[i]);
            //Print(cat_frames[i]);
            //Print(L"\n");
            uefi_call_wrapper(gBS->Stall, 1, 300000);
        }
    }

    return EFI_SUCCESS;
}

