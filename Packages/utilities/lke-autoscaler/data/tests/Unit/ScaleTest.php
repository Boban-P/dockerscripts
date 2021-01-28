<?php

namespace AutoScaler\tests\Unit;

use AutoScaler\Scale;
use PHPUnit\Framework\TestCase;

class ScaleTest extends TestCase
{
    /**
     * @covers \AutoScaler\Scale
     */
    public function testScale()
    {
        $scale = new Scale(75, 70, 72, 5);
        $this->assertTrue($scale->scaleCount() == 0);

        $scale = new Scale(75, 70, 80, 15);
        $this->assertTrue($scale->scaleCount() == 1);

        $scale = new Scale(75, 70, 80, 16);
        $this->assertTrue($scale->scaleCount() == 2);

        $scale = new Scale(75, 70, 60, 5);
        $this->assertTrue($scale->scaleCount() == -1);

        $scale = new Scale(75, 70, 60, 4);
        $this->assertTrue($scale->scaleCount() == 0);
    }

}