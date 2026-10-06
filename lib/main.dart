import 'package:flutter/material.dart';
import 'package:tugas_slicing/pages/homepage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyApplication();
  }
}

class MyApplication extends StatefulWidget {
  const MyApplication({super.key});

  @override
  State<MyApplication> createState() => _MyApplicationState();
}

class _MyApplicationState extends State<MyApplication> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Belajar Flutter",
      // theme: ThemeData(
      //   primarySwatch: Colors.deepPurple,
      //   fontFamily: "RobotoSlab",
      // ),
      home: const Homepage(),
    );
  }
}

class LatihanCheckBox extends StatefulWidget {
  const LatihanCheckBox({super.key});

  @override
  State<LatihanCheckBox> createState() => _LatihanCheckBoxState();
}

class _LatihanCheckBoxState extends State<LatihanCheckBox> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: const Text("Laki-laki"),
      activeColor: Colors.black,
      hoverColor: Colors.green,
      checkColor: Colors.blue,
      controlAffinity: ListTileControlAffinity.leading,
      value: isChecked,
      onChanged: (val) {
        setState(() {
          isChecked = val ?? false;
        });
      },
    );
  }
}

class LatihanRadio extends StatefulWidget {
  const LatihanRadio({super.key});

  @override
  State<LatihanRadio> createState() => _LatihanRadioState();
}

class _LatihanRadioState extends State<LatihanRadio> {
  String gender = "L";

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Column(
        children: [
          Radio<String>(
            value: "L",
            groupValue: gender,
            onChanged: (val) {
              setState(() {
                gender = val!;
              });
            },
          ),
          Radio<String>(
            value: "P",
            groupValue: gender,
            onChanged: (val) {
              setState(() {
                gender = val!;
              });
            },
          ),
        ],
      ),
    );
  }
}

class LatihanDropDown extends StatefulWidget {
  const LatihanDropDown({super.key});

  @override
  State<LatihanDropDown> createState() => _LatihanDropDownState();
}

class _LatihanDropDownState extends State<LatihanDropDown> {
  String? selectedJurusan;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      hint: Text(selectedJurusan ?? "Pilih Jurusan"),
      value: selectedJurusan,
      items: const [
        DropdownMenuItem(value: "TKJ", child: Text("TKJ")),
        DropdownMenuItem(value: "RPL", child: Text("RPL")),
        DropdownMenuItem(value: "PSPT", child: Text("PSPT")),
      ],
      onChanged: (val) {
        setState(() {
          selectedJurusan = val;
        });
      },
    );
  }
}

class LatihanSwitch extends StatefulWidget {
  const LatihanSwitch({super.key});

  @override
  State<LatihanSwitch> createState() => _LatihanSwitchState();
}

class _LatihanSwitchState extends State<LatihanSwitch> {
  bool isActive = false;
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          title: const Text("Notifikasi"),
          value: isActive,
          activeThumbColor: Colors.black87,
          onChanged: (val) {
            setState(() {
              isActive = val;
            });
          },
        ),

        SwitchListTile(
          title: const Text("Mode Gelap"),
          value: isDarkMode,
          activeThumbColor: Colors.black87,
          onChanged: (val) {
            setState(() {
              isDarkMode = val;
            });
          },
        ),
      ],
    );
  }
}

class LatihanSlider extends StatefulWidget {
  const LatihanSlider({super.key});

  @override
  State<LatihanSlider> createState() => _LatihanSliderState();
}

class _LatihanSliderState extends State<LatihanSlider> {
  double value = 0;

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: value,
      min: 0,
      max: 100,
      divisions: 20,
      activeColor: Colors.greenAccent,
      label: value.toString(),
      onChanged: (val) {
        setState(() {
          value = val;
          print(val);
        });
      },
    );
  }
}

class LatihanDatePicker extends StatefulWidget {
  const LatihanDatePicker({super.key});

  @override
  State<LatihanDatePicker> createState() => _LatihanDatePickerState();
}

class _LatihanDatePickerState extends State<LatihanDatePicker> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
          initialDate: DateTime.now(),
        );

        if (date != null) {
          setState(() {
            selectedDate = date;
          });
        }
      },
      child: const Text("Pilih tanggal"),
    );
  }
}

class LatihanTimePicker extends StatefulWidget {
  const LatihanTimePicker({super.key});

  @override
  State<LatihanTimePicker> createState() => _LatihanTimePickerState();
}

class _LatihanTimePickerState extends State<LatihanTimePicker> {
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (time != null) {
          setState(() {
            selectedTime = time;
            print(time);
          });
        }
      },
      child: Text("Pilih Waktu"),
    );
  }
}
