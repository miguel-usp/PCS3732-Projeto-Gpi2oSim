import tkinter as tk


class Gpio():
    def __init__(self, gpio_number, pin_number, direction, state):
        self.gpio_number = gpio_number
        self.pin_number = pin_number
        self.direction = direction
        self.state = state


class GPIODisplay(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("GPIO Display")
        self.geometry("500x820")

        self.canvas = tk.Canvas(self, bg="white", height=820, width=500)
        self.canvas.pack()

        self.pins = []
        self.gpios = []
        self.create_pins()

    def create_pins(self):
        # Definição dos labels conforme a imagem fornecida
        labels_left = [
            "3.3 VDC\nPower", "GPIO 8",
            "GPIO 9", "GPIO 7",
            "Ground", "GPIO 0",
            "GPIO 2", "GPIO 3",
            "3.3 VDC\nPower", "GPIO 12",
            "GPIO 13", "GPIO 14",
            "Ground", "SDA0",
            "GPIO 21", "GPIO 22",
            "GPIO 23", "GPIO 24",
            "GPIO 25", "Ground"
        ]

        labels_right = [
            "5.0 VDC\nPower", "5.0 VDC\nPower",
            "Ground", "GPIO 15",
            "GPIO 16", "GPIO 1",
            "Ground", "GPIO 4",
            "GPIO 5", "Ground",
            "GPIO 6", "GPIO 10",
            "GPIO 11", "SCL0",
            "Ground", "GPIO 26",
            "Ground", "GPIO 27",
            "GPIO 28", "GPIO 29"
        ]

        self.canvas.create_rectangle(
            190, 2, 310, 810, fill="#d3d3d3", outline="black", width=2, )

        for i in range(20):
            for j in range(2):
                x0 = 70 * j + 200
                y0 = 40 * i + 10
                x1 = x0 + 30
                y1 = y0 + 30
                pin_number = i*2+j+1

                if j == 0:
                    label_text = labels_left[i]
                    # Labels à esquerda dos GPIOs da primeira coluna
                    self.canvas.create_text(
                        x0 - 30, (y0 + y1) / 2, text=label_text, anchor="e")
                else:
                    label_text = labels_right[i]
                    # Labels à direita dos GPIOs da segunda coluna
                    self.canvas.create_text(
                        x1 + 30, (y0 + y1) / 2, text=label_text, anchor="w")

                if label_text.startswith("GPIO"):
                    pin = self.canvas.create_oval(
                        x0, y0, x1, y1, fill='light blue', tags=f"pin{pin_number}")
                    gpio = Gpio(gpio_number=int(label_text.split()[
                                1]), pin_number=pin_number, direction="out", state="low")
                    self.gpios.append(gpio)
                elif label_text.startswith("3.3") or label_text.startswith("5.0"):
                    pin = self.canvas.create_oval(
                        x0, y0, x1, y1, fill='red', tags=f"pin{pin_number}")
                elif label_text.startswith("Ground"):
                    pin = self.canvas.create_oval(
                        x0, y0, x1, y1, fill='grey32', tags=f"pin{pin_number}")
                else:
                    pin = self.canvas.create_oval(
                        x0, y0, x1, y1, fill='grey', tags=f"pin{pin_number}")
                self.canvas.create_text(x0+15, y0+15, text=pin_number)
                self.pins.append(pin)

        # self.turn_gpio_high(gpio_number=int(22))

    def turn_gpios_high(self, gpios_list):
        visited = []
        for gpio_num, gpio_in_out, gpio_high_low in gpios_list:
            visited.append(gpio_num)
            for gpio in self.gpios:
                if gpio.gpio_number == gpio_num:
                    if gpio_in_out == 1:
                        self.canvas.itemconfig(
                            f"pin{gpio.pin_number}", fill='yellow')
                        gpio.state = "high"
                    else:
                        self.canvas.itemconfig(
                            f"pin{gpio.pin_number}", fill='orange')
                        gpio.state = "high"
        for gpio in self.gpios:
            if gpio.gpio_number not in visited:
                self.canvas.itemconfig(
                    f"pin{gpio.pin_number}", fill='light blue')
                gpio.state = "low"


if __name__ == "__main__":
    app = GPIODisplay()
    app.mainloop()
