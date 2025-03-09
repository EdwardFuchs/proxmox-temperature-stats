#!/bin/bash

PVE_NODES_FILE="/usr/share/perl5/PVE/API2/Nodes.pm"
PVE_MANAGERLIB_FILE="/usr/share/pve-manager/js/pvemanagerlib.js"

PVE_NODES_FILE_BKP="${PVE_NODES_FILE}_ORI"
PVE_MANAGERLIB_FILE_BKP="${PVE_MANAGERLIB_FILE}_ORI"

THERMAL_TPL="            
    {
        itemId: 'thermal',
        colspan: 2,
        printBar: false,
        title: gettext('CPU Thermal State'),
        textField: 'thermalstate',
        renderer:function(value){
            const c0 = value.match(/Core 0.*?\+([\d\.]+)Â/)[1];
            const c1 = value.match(/Core 1.*?\+([\d\.]+)Â/)[1];
            const c2 = value.match(/Core 2.*?\+([\d\.]+)Â/)[1];
            const c3 = value.match(/Core 3.*?\+([\d\.]+)Â/)[1];
            const c4 = value.match(/Core 4.*?\+([\d\.]+)Â/)[1];
            const c5 = value.match(/Core 5.*?\+([\d\.]+)Â/)[1];
            const c6 = value.match(/Core 6.*?\+([\d\.]+)Â/)[1];
            const c7 = value.match(/Core 7.*?\+([\d\.]+)Â/)[1];
            const c8 = value.match(/Core 8.*?\+([\d\.]+)Â/)[1];
            const c9 = value.match(/Core 9.*?\+([\d\.]+)Â/)[1];
            const c10 = value.match(/Core 10.*?\+([\d\.]+)Â/)[1];
            const c11 = value.match(/Core 11.*?\+([\d\.]+)Â/)[1];
            const c12 = value.match(/Core 12.*?\+([\d\.]+)Â/)[1];
            const c13 = value.match(/Core 13.*?\+([\d\.]+)Â/)[1];
            const c14 = value.match(/Core 14.*?\+([\d\.]+)Â/)[1];
            const c15 = value.match(/Core 15.*?\+([\d\.]+)Â/)[1];
            const c16 = value.match(/Core 16.*?\+([\d\.]+)Â/)[1];
            const c17 = value.match(/Core 17.*?\+([\d\.]+)Â/)[1];
            const c18 = value.match(/Core 18.*?\+([\d\.]+)Â/)[1];
            const c19 = value.match(/Core 19.*?\+([\d\.]+)Â/)[1];
            const c20 = value.match(/Core 20.*?\+([\d\.]+)Â/)[1];
            const c21 = value.match(/Core 21.*?\+([\d\.]+)Â/)[1];
            const c22 = value.match(/Core 22.*?\+([\d\.]+)Â/)[1];
            const c23 = value.match(/Core 23.*?\+([\d\.]+)Â/)[1];
            const c24 = value.match(/Core 24.*?\+([\d\.]+)Â/)[1];
            const c25 = value.match(/Core 25.*?\+([\d\.]+)Â/)[1];
            const c26 = value.match(/Core 26.*?\+([\d\.]+)Â/)[1];
            const c27 = value.match(/Core 27.*?\+([\d\.]+)Â/)[1];
            const c28 = value.match(/Core 28.*?\+([\d\.]+)Â/)[1];
            const c29 = value.match(/Core 29.*?\+([\d\.]+)Â/)[1];
            const c30 = value.match(/Core 30.*?\+([\d\.]+)Â/)[1];
            const c31 = value.match(/Core 31.*?\+([\d\.]+)Â/)[1];
            return \`Core 0: ${c0} ℃  | Core 0: ${c1} ℃  | Core 0: ${c2} ℃  | Core 0: ${c3} ℃  | Core 0: ${c4} ℃  | Core 0: ${c5} ℃  | Core 0: ${c6} ℃  | Core 0: ${c7} ℃  | Core 0: ${c8} ℃  | Core 0: ${c9} ℃  | Core 0: ${c10} ℃  | Core 0: ${c11} ℃  | Core 0: ${c12} ℃  | Core 0: ${c13} ℃  | Core 0: ${c14} ℃  | Core 0: ${c15} ℃  | Core 0: ${c16} ℃  | Core 0: ${c17} ℃  | Core 0: ${c18} ℃  | Core 0: ${c19} ℃  | Core 0: ${c20} ℃  | Core 0: ${c21} ℃  | Core 0: ${c22} ℃  | Core 0: ${c23} ℃  | Core 0: ${c24} ℃  | Core 0: ${c25} ℃  | Core 0: ${c26} ℃  | Core 0: ${c27} ℃  | Core 0: ${c28} ℃  | Core 0: ${c29} ℃  | Core 0: ${c30} ℃  | Core 0: ${c31} ℃\`
        }
    }"


function installPackages() {
    apt-get install -y wget lm-sensors
}

function injectNodes() {
    if grep -q "res->{thermalstate}" $PVE_NODES_FILE; then
        echo "Sensors already injected to nodes file!!!"
        exit 1
    else
        echo "Sensors injection to nodes file not found, injecting..."

        echo "- backup original file: $PVE_NODES_FILE to $PVE_NODES_FILE_BKP"     
        # Copy the source file to the destination file  
        cp "$PVE_NODES_FILE" "$PVE_NODES_FILE_BKP"
        
        # Find the dinfo block and add thermal template
        sed -i 's/my $dinfo = df('\''\/'\''\, 1);/$res->{thermalstate} = `sensors`;\n&/' $PVE_NODES_FILE
    fi
}

function injectTemplate() {
    if grep -q "CPU Thermal State" $PVE_MANAGERLIB_FILE; then
        echo "Sensors already injected to nodes js file!!!"
        exit 1
    else
        echo "Sensors injection to pve manager js file not found, injecting..."

        echo "- backup original file: $PVE_MANAGERLIB_FILE to $PVE_MANAGERLIB_FILE_BKP"
        # Copy the source file to the destination file
        cp "$PVE_MANAGERLIB_FILE" "$PVE_MANAGERLIB_FILE_BKP"
        
        echo "Adding thermal template:\n$THERMAL_TPL"       
        # Define the temporary file
        tmpfile=$(mktemp)
        
        # Find the PVE Manager Version block and add thermal template
        awk -v var="$THERMAL_TPL" '/PVE Manager Version/ {p=1} p && /},/ {print; print var; p=0; next} 1' "$PVE_MANAGERLIB_FILE" > "$tmpfile"

        # Overwrite the original file with the modified content
        mv "$tmpfile" "$PVE_MANAGERLIB_FILE"
        chmod 644 "$PVE_MANAGERLIB_FILE"
        
        echo "Template fix: Change $PVE_MANAGERLIB_FILE file to match exact sensors output count inside the thermal template block"
        echo "<<< !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>"
        echo "If something bad occur, restore original files with:"
        echo "# apt install --reinstall pve-manager proxmox-widget-toolkit libjs-extjs"
        echo "<<< !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! >>>"
    fi
}

function init() {
    installPackages
    injectNodes
    injectTemplate

    systemctl restart pveproxy
}

init
