//
// (C) Copyright 2021 Intel Corporation.
//
// SPDX-License-Identifier: BSD-2-Clause-Patent
//

package cmdutil

import (
	"context"
	"encoding/json"
	"os"

	"github.com/pkg/errors"

	"github.com/daos-stack/daos/src/control/lib/hardware"
	"github.com/daos-stack/daos/src/control/lib/hardware/hwloc"
)

// DumpTopologyCmd implements a go-flags Commander that dumps
// the system topology to stdout or to a file.
type DumpTopologyCmd struct {
	LogCmd
	Output string `short:"o" long:"output" default:"stdout" description:"Dump output to this location"`
	JSON   bool   `short:"j" long:"json" description:"Enable JSON output"`
}

func (cmd *DumpTopologyCmd) Execute(_ []string) error {
	out := os.Stdout
	if cmd.Output != "stdout" {
		f, err := os.Create(cmd.Output)
		if err != nil {
			return errors.Wrapf(err, "failed to create %q", cmd.Output)
		}
		defer f.Close()
		out = f
	}

	hwProv := hwloc.NewProvider(cmd.Logger)
	topo, err := hwProv.GetTopology(context.Background())
	if err != nil {
		return err
	}

	if !cmd.JSON {
		return hardware.PrintTopology(topo, out)
	}

	data, err := json.MarshalIndent(topo, "", "  ")
	if err != nil {
		return err
	}
	_, err = out.Write(append(data, []byte("\n")...))
	return err
}
