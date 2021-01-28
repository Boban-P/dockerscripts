<?php


namespace AutoScaler;


class Scale
{
    public float $thresholdUpPercentage;
    public float $thresholdDownPercentage;
    public float $usedPercentage;
    public int $nodes;

    public function __construct(float $thresholdUpPercentage, float $thresholdDownPercentage, float $usedPercentage, int $nodes)
    {
        $this->thresholdUpPercentage = $thresholdUpPercentage;
        $this->thresholdDownPercentage = $thresholdDownPercentage;
        $this->usedPercentage = $usedPercentage;
        $this->nodes = $nodes;
    }

    public function scaleUp()
    {
        return max(0, ceil(($this->usedPercentage - $this->thresholdUpPercentage) * $this->nodes / $this->thresholdUpPercentage));
    }

    public function scaleDown()
    {
        return max(0, floor(($this->thresholdDownPercentage - $this->usedPercentage) * $this->nodes / $this->thresholdDownPercentage));
    }

    public function scaleCount() {
        if ( $this-> usedPercentage > $this->thresholdUpPercentage) {
            return intval((($this->usedPercentage - $this->thresholdUpPercentage) * $this->nodes - 1) / $this->thresholdUpPercentage) + 1;
        }
        elseif ($this->usedPercentage < $this->thresholdDownPercentage) {
            return intval(($this->usedPercentage - $this->thresholdDownPercentage) * $this->nodes / $this->thresholdDownPercentage);
        }
        else {
            return 0;
        }
    }
}
